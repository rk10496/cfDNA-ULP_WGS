refFlatb37=/bgfs/soesterreich/pan_data/soesterreich/Tendo/ReferenceFiles/hg19_Versions/ucsc.hg19.fasta/refFlatB37.txt
CNVkitScripts=/bgfs/soesterreich/pan_data/soesterreich/Tendo/InstalledTools/CNVkit/cnvkit/scripts
sampleList=/bgfs/soesterreich/pan_data/soesterreich/Tendo/Projects/Project5_ULP_WGS/20200401_Second_Batch_47_Samples_No_Normal/sampleList.txt
out=/bgfs/soesterreich/pan_data/soesterreich/Tendo/Projects/Project5_ULP_WGS/20200401_Second_Batch_47_Samples_No_Normal/03_CNA_Annotation_CNVkit_By_Gene

module load cnvkit/0.9.5

while read sample

do

file1=/bgfs/soesterreich/pan_data/soesterreich/Tendo/InstalledTools/ichorCNA/scripts/snakemake/results/ichorCNA/$sample/$sample.cna.seg
file2=$out/temp/edit1.cnr
file3=$out/temp/edit2.cnr
file4=$out/temp/edit3.cnr
cnv_file=$out/temp/reheader.cnr

awk '{$3=$3" "0; print }' OFS='\t' $file1 > $file2
awk 'NR==1 {gsub("chr","chromosome");gsub(".*.logR","log2",$7);gsub("0","gene",$4);print};1' OFS='\t' $file2 > $file3
awk '{gsub("0","-",$4);print}' OFS='\t' $file3 > $file4
awk '{if (NR!=1) {print}}' OFS='\t' $file4 > $cnv_file

$CNVkitScripts/cnv_annotate.py $refFlatb37 $cnv_file \
-o $out/$sample.annoated.cnr


done < $sampleList
