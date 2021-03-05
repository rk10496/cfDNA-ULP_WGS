refFlatb37=/WOrkingDirectory/refFlatB37.txt
CNVkitScripts=/WOrkingDirectory/sampleList.txt
out=/WOrkingDirectory/

module load cnvkit/0.9.5

while read sample

do

file1=/WOrkingDirectory/$sample.cna.seg
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
