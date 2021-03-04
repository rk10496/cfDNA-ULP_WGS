#!/bin/bash
#
#SBATCH --job-name=ichorCNAannotation
#SBATCH -N 1
#SBATCH --cpus-per-task=8 # Request that ncpus be allocated per process.
#SBATCH -t 1-00:00 # Runtime in D-HH:MM
#SBATCH --output=/bgfs/soesterreich/pan_data/soesterreich/Tendo/Projects/Project6_ULP_WGS/ichorCNA_Reanalysis/ichorCNAannotation.out

module purge
module load cnvkit/0.9.5

refFlatb37=/bgfs/soesterreich/pan_data/soesterreich/Tendo/ReferenceFiles/hg19_Versions/hg19/refFlatB37.txt
CNVkitScripts=/bgfs/soesterreich/pan_data/soesterreich/Tendo/InstalledTools/CNVkit/cnvkit/scripts
target=/bgfs/soesterreich/pan_data/soesterreich/Tendo/Projects/Project6_ULP_WGS/ichorCNA_Reanalysis/all_CNA_file_gene_annotated
sampleList=/bgfs/soesterreich/pan_data/soesterreich/Tendo/Projects/Project6_ULP_WGS/sampleList.txt

while read sample
do

CNAfile=/bgfs/soesterreich/pan_data/soesterreich/Tendo/Projects/Project6_ULP_WGS/ichorCNA_Reanalysis/all_CNA_file/$sample.cna.seg
file1=$target/edit1.cnr
file2=$target/edit2.cnr
file3=$target/edit3.cnr
file4=$target/$sample.cnr
awk '{$3=$3" "0; print }' OFS='\t' $CNAfile > $file1
awk 'NR==1 {gsub("chr","chromosome");gsub(".*.logR","log2",$7);gsub("0","gene",$4);print};1' OFS='\t' $file1 > $file2
awk '{gsub("0","-",$4);print}' OFS='\t' $file2 > $file3
awk '{if (NR!=1) {print}}' OFS='\t' $file3 > $file4

rm $file1 
rm $file2 
rm $file3

cnv_file=$file4
out=$target/$sample.annotated.cnr


$CNVkitScripts/cnv_annotate.py $refFlatb37 $cnv_file \
-o $out

rm $file4

done < $sampleList