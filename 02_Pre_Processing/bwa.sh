#!/bin/bash

################# variables for job submission #####################

nodes=1
ppn=12
wt=3-00:00
version=0.7.13

################# modules required #####################

module load gcc/8.2.0 bwa/0.7.17
module load gcc/8.2.0 samtools/1.9
module load picard/2.18.12
module load gatk/4.1.2.0
picardPath=/ihome/crc/install/picard/2.18.12
gatkPath=/ihome/crc/install/gatk/GenomeAnalysisTK-3.8-1

################# unchanged varianbles #####################

hg19_fasta=/WorkingDirectory/ucsc.hg19.fasta
hg19_2bit=/WorkingDirectory/hg19.2bit
b37_fasta=/WorkingDirectory/human_g1k_v37.fasta
b37_2bit=/WorkingDirectory/human_g1k_v37.2bit
dbsnpVCF=/WorkingDirectory/dbsnp_138.hg19.vcf
Indels1000g=/WorkingDirectory/1000G_phase1.indels.hg19.sites.vcf
Indels1000gGoldStandard=/WorkingDirectory/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf

################# variables to be changed #####################

##sample=ULP_WGS

BwaOption=mem
#choose between "aln" or "mem"
fastqFolder=/WorkingDirectory/all_fastq
out=/WorkingDirectory/all_bam_hg19/
#mkdir $out
sampleList=/WorkingDirectory/sampleList.txt

################# job submission loop #####################
while read sample
do

aligned_out=$out/$sample.bwa_$version_$BwaOption
mkdir $aligned_out

sampleR1=$fastqFolder/${sample}.R1.fastq
sampleR2=$fastqFolder/${sample}.R2.fastq

echo "#!/bin/bash
#
#SBATCH --job-name=$sample.bwa.$BwaOption
#SBATCH -N 1
#SBATCH --cpus-per-task=8 # Request that ncpus be allocated per process.
#SBATCH -t 1-00:00 # Runtime in D-HH:MM
#SBATCH --output=$aligned_out/$sample.bwa.out

cd $aligned_out

if [ "$BwaOption" = "aln" ]
then
  echo "Bwa is aln"
  bwa aln $hg19_fasta $sampleR1 > $sample.R1.sai
  bwa aln $hg19_fasta $sampleR2 > $sample.R2.sai
  bwa sampe $hg19_fasta $sample.R1.sai $sample.R1.sai $sampleR1 $sampleR2 > $sample.bwa.$BwaOption.sam

elif [ "$BwaOption" = "mem" ]
then
  echo "Bwa is mem"
  bwa mem -M $hg19_fasta $sampleR1 $sampleR2 > $sample.bwa.$BwaOption.sam


else 
 echo "Bwa option is not specified"
fi

samtools view -bS -@ $ppn $sample.bwa.$BwaOption.sam > $sample.bwa.bam  
samtools sort -@ $ppn -m 2G -o $sample.bwa.sorted.bam -T $sample.bwa.sorted.temp.bam $sample.bwa.bam 
samtools index $sample.bwa.sorted.bam

java -Xmx50g -jar $picardPath/picard.jar MarkDuplicates I=$sample.bwa.sorted.bam O=$sample.bwa.sorted.dedup.bam CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=output.metrics 
java -Xmx28g -jar $picardPath/picard.jar AddOrReplaceReadGroups I=$sample.bwa.sorted.dedup.bam O=$sample.bwa.sorted.dedup.rg.bam SO=coordinate RGID=id RGLB=agilentWXS RGPL=illumina RGPU=illuminaSeq RGSM=$sample 

samtools index $sample.bwa.sorted.dedup.rg.bam

gatk BQSRPipelineSpark \
    -R hg19_fasta \
   --known-sites /WorkingDirectory/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
   --known-sites /WorkingDirectory/1000G_phase1.indels.hg19.sites.vcf \
   --known-sites /WorkingDirectory/dbsnp_138.hg19.vcf.gz \
   -I $sample.bwa.sorted.dedup.rg.bam \
   -O $sample.bwa.gatk.final.bam \
    --conf "spark.local.dir=$LOCAL"

java -jar $gatkPath/GenomeAnalysisTK.jar \
   -T BaseRecalibrator \
   -R $hg19_fasta \
   -I $sample.bwa.sorted.dedup.rg.bam \
   -knownSites $Indels1000g \
   -knownSites $Indels1000gGoldStandard \
   -o $sample.recalibration.table

gatk ApplyBQSR \
   -R $hg19_fasta \
   -I $sample.bwa.sorted.dedup.rg.bam \
   --bqsr-recal-file $sample.recalibration.table \
   -O $sample.bwa.$BwaOption.gatk.final.bam

rm $sample.bwa.$BwaOption.gatk.final.bam
samtools index $sample.bwa.$BwaOption.gatk.final.bam





echo \"

$sample fastq paired-end reads aligned with bwa, converted to .bam, sorted, duplicate marked and indel realigned using bwa=>gatk and files... 
$sampleR1
$sampleR2

\"

" > $aligned_out/$sample-bwa.sbatch

sbatch $aligned_out/$sample-bwa.sbatch

done < $sampleList
