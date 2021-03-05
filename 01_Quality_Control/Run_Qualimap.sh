#!/bin/bash


qualimapPath=/Qualimap/qualimap_v2.2.1
sampleList=/WorkingDirectory/sampleList.txt

while read sample
do

outdir=/WorkingDirectory/$sample
mkdir $outdir
file=/WorkingDirectory/$sample.bam

echo "#!/bin/bash
#
#SBATCH --job-name=qualimap
#SBATCH -N 1
#SBATCH --cpus-per-task=12 # Request that ncpus be allocated per process.
#SBATCH -t 1-00:00 # Runtime in D-HH:MM
#SBATCH --output=/WorkingDirectory/$sample.out

unset DISPLAY

cd $qualimapPath
./qualimap bamqc \
-bam $file \
-outdir $outdir \
-outfile $sample.Qualimap.pdf

" > $outdir/$sample.sbatch

sbatch $outdir/$sample.sbatch

done < $sampleList


