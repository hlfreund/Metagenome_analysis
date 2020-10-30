#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12 # must match the # of threads (-t #)
##SBATCH --mem-per-cpu=500G # * if threading, do not let this line run (use ##). Cannot ask for too much memory per cpu!
#SBATCH --time=7-00:00:00     # 7 days, 0 hrs
#SBATCH --output=SS_mgm_assembly_2_10.28.20.stdout
#SBATCH --mail-user=hfreu002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name="Assembling MGMs with merged + unmerged reads"
#SBATCH -p highmem
# you can use any of the following: intel, batch, highmem, gpu

cd /bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/

today=$(date "+%m.%d.%y") # date is the command to get today's date, and the "+%m_%d_%y" will print it in month_day_year format

module load megahit/1.2.9

for i in *_R1_CLEANEST.fastq;
do
    SAMPLE=$(echo ${i} | sed "s/_L001_R1_\CLEANEST\.fastq//")
    echo ${SAMPLE}_L001_R1_CLEANEST.fastq ${SAMPLE}_L001_R2_CLEANEST.fastq
    
     megahit -1 ${SAMPLE}_L001_R1_CLEANEST.fastq -2 ${SAMPLE}_L001_R2_CLEANEST.fastq -r ${SAMPLE}_L001_merged.fastq -t 12 -o ./megahit_${SAMPLE}_assembly_${today}
    
done

## Tips for Running on High-Performance Cluster - w/ a SLURM ( Simple Linux Utility for Resource Management) system
# when submitting this as a job, must request a total memory allocation rather than memory per cpu because we are threading, and memory is limited on certain high-memory nodes
# sbatch --mem=700gb script.sh
## --mem=700gb --> how to request for total allocation of mem rather than mem per cpu; must include in job submission command

### MEGAHIT assembly tips
# for ultra complex metagenomics data such as soil, a larger kmin, say 27, is recommended to reduce the complexity of the de Bruijn graph.
### Quality trimming is also recommended
# --min-count 2 ----> (kmin+1)-mer with multiplicity lower than d (default 2, specified by --min-count option) will be discarded;
### recommend using the default value 2 for metagenomics assembly

## MORE MEGAHIT TIPS: https://sites.google.com/site/wiki4metagenomics/tools/assembly/megahit
