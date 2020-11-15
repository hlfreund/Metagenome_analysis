#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=500G  # max you can get in batch nodes
#SBATCH --time=5-00:00:00     # 5 days
#SBATCH --output=bbmerge_normalized_mgms_11.13.20.stdout
#SBATCH --mail-user=hfreu002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name="Merging Normalized Metagenomes"
#SBATCH -p highmem
# you can use any of the following: intel, batch, highmem, gpu

cd /bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/

today=$(date "+%m.%d.%y") # date is the command to get today's date, and the "+%m_%d_%y" will print it in month_day_year format

module load BBMap/38.86

for i in *_R1_normalized.fastq;
do
    SAMPLE=$(echo ${i} | sed "s/_L001_R1_normalized.fastq//")
    echo ${SAMPLE}
    
    bbmerge-auto.sh -Xmx500g in1=${SAMPLE}_L001_R1_normalized.fastq in2=${SAMPLE}_L001_R2_normalized.fastq out=${SAMPLE}_normalized_merged.fastq outu=${SAMPLE}_normalized_unmerged.fastq ihist=${SAMPLE}_ihist_${today}.txt ecct extend2=20

done

### *** confirm what the input files need to be and adjust file names for each in= ^^^

#     /Volumes/HLF_SSD/Aronson_Lab_Data/bbmap/bbmerge-auto.sh in1=${SAMPLE}_R1_CLEANEST.fastq in2=${SAMPLE}_R2_CLEANEST.fastq out=${SAMPLE}_merged.fastq outu=${SAMPLE}_unmerged.fq ihist=${SAMPLE}_ihist.txt ecct extend2=20
