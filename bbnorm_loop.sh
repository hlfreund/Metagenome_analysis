#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12 # must match the # of threads (-t #)
##SBATCH --mem-per-cpu=500G # * if threading, do not let this line run (use ##). Cannot ask for too much memory per cpu!
#SBATCH --time=10-00:00:00     # 7 days, 0 hrs
#SBATCH --output=Spades_mgm_assembly_11.9.20.stdout
#SBATCH --mail-user=hfreu002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name="Assembling MGMs with Spades 11/9/2020"
#SBATCH -p highmem
# you can use any of the following: intel, batch, highmem, gpu

cd /bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/

Path="/bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/"

today=$(date "+%m.%d.%y") # date is the command to get today's date, and the "+%m_%d_%y" will print it in month_day_year format

module load BBMap/38.86

if [[ ! -d ${Path}/bbnorm_${today} ]]; then
    mkdir ${Path}/bbnorm_mgm_${today}
fi

for i in *_R1_CLEANEST.fastq;
do
    SAMPLE=$(echo ${i} | sed "s/_L001_R1_CLEANEST.fastq//")
    echo ${SAMPLE}_L001_R1_CLEANEST.fastq ${SAMPLE}_L001_R2_CLEANEST.fastq
    
    if [[ -s ${Path}/bbnorm_mgm_${today}/${SAMPLE}_L001_R1_normalized.fastq ]] && [[ -s ${Path}/bbnorm_mgm_${today}/${SAMPLE}_L001_R2_normalized.fastq ]]; then
    
    bbnorm.sh in1=${SAMPLE}_L001_R1_CLEANEST.fastq in2=${SAMPLE}_L001_R2_CLEANEST.fastq out1=${SAMPLE}_L001_R1_normalized.fastq out2=${SAMPLE}_L001_R2_normalized.fastq target=100 min=5
    
    mv ${SAMPLE}_L001_R1_normalized.fastq ${SAMPLE}_L001_R2_normalized.fastq ${Path}/bbnorm_mgm_${today}/

    fi
        
done

#echo -e "Finished \aall assemblies with SPades"

#bbnorm.sh in=reads.fq out=normalized.fq target=100 min=5



