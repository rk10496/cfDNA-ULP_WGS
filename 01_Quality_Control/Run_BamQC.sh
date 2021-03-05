#!/bin/bash



sampleList=/WorkingDirectory/samplelist1.txt
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

module load bamqc
bamqc -o $outdir $file 

" > $outdir/$sample.sbatch

sbatch $outdir/$sample.sbatch

done < $sampleList


