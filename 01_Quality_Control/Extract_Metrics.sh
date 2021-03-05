
#!/bin/bash
#
cd /WorkingDirectory/

outFile=/WorkingDirectory/Metrics.txt
echo -n "Sample_Code" > $outFile
echo -n -e "\t" >> $outFile
echo -n "Coverage" >> $outFile
echo -n -e "\t" >> $outFile
echo -n "Number_Bases" >> $outFile
echo -n -e "\t" >> $outFile
echo -n "Number_Mapped_Reads" >> $outFile
echo -n -e "\t" >> $outFile
echo -n "MisMatch_Rate" >> $outFile
echo -n -e "\t" >> $outFile
echo "Median_Insert_Size" >> $outFile

sampleList=/WorkingDirectory/sampleList.txt
while read sample
do
file=/WorkingDirectory/$sample/QualimapOutput.txt
#extract only numbers \
string1_1=$(awk 'NR==70' $file)
string1_2=$(echo $string1_1 | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
string1_3=$(echo $string1_2 | sed -e 's/^[[:space:]]*//')
#extract the part after the first equal sign
string2_1=$(awk 'NR==12' $file)
string2_2=$(cut -d "=" -f2- <<< "$string2_1")
string2_3=$(echo $string2_2 | sed -e 's/^[[:space:]]*//')
#extract the part after the first equal sign
string3_1=$(awk 'NR==21' $file)
string3_2=$(cut -d "=" -f2- <<< "$string3_1")
string3_3=$(echo $string3_2 | sed -e 's/^[[:space:]]*//')
#extract only numbers \
string4_1=$(awk 'NR==59' $file)
string4_2=$(echo $string4_1 | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
string4_3=$(echo $string4_2 | sed -e 's/^[[:space:]]*//')
#extract only numbers \
string5_1=$(awk 'NR==38' $file)
string5_2=$(echo $string5_1 | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
string5_3=$(echo $string5_2 | sed -e 's/^[[:space:]]*//')


#echo "Sample_Code" > test.txt
#echo -n "Coverage" >> file.txt
echo -n $sample >> $outFile
echo -n -e "\t" >> $outFile
echo -n $string1_3 >> $outFile
echo -n -e "\t" >> $outFile
echo -n $string2_3 >> $outFile
echo -n -e "\t" >> $outFile
echo -n $string3_3 >> $outFile
echo -n -e "\t" >> $outFile
echo -n $string4_3 >> $outFile
echo -n -e "\t" >> $outFile
echo -n $string5_3 >> $outFile
echo -e "\t" >> $outFile

done < $sampleList
