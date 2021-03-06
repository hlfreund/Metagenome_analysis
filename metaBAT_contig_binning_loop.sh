#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4 # must match the # of threads (-t #)
##SBATCH --mem-per-cpu=500G # * if threading, do not let this line run (use ##). Cannot ask for too much memory per cpu!
#SBATCH --time=10-00:00:00     # 7 days, 0 hrs
#SBATCH --output=metaBAT_contig_binning_11.16.20.stdout
#SBATCH --mail-user=hfreu002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name="Binning contigs from assembled mgms with metaBAT 11/16/2020"
#SBATCH -p highmem
# you can use any of the following: intel, batch, highmem, gpu

cd /bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/ # change to your desired directory

Path="/bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/" # initiate your path for later

today=$(date "+%m.%d.%y") # date is the command to get today's date, and the "+%m_%d_%y" will print it in month_day_year format

module load metabat/0.32.4 # load the module on your computing cluster system (ignore this if running locally)

for i in *_contigs.fasta;
do
    SAMPLE=$(echo ${i} | sed "s/_contigs.fasta//")
    echo ${SAMPLE} " -- binning contigs in this metagenome"
    
    jgi_summarize_bam_contig_depths --outputDepth ${SAMPLE}_depth.txt ${SAMPLE}_bam.bam
    
    metabat2 -t 4 ${SAMPLE}_contigs.fasta -a ${SAMPLE}_depth.txt -o ${SAMPLE}_contig_bins/bin -v

done

### * bam files must be sorted first
### ${SAMPLE}_depth.txt -- includes mean and variance of base coverage depth
