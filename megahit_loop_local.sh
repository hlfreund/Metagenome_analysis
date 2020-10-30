#!/bin/bash -l

cd /Volumes/HLF_SSD/Aronson_Lab_Data/SaltonSea_POW

today=$(date "+%m.%d.%y") # date is the command to get today's date, and the "+%m_%d_%y" will print it in month_day_year format

for i in *_R1_CLEANEST.fastq;
do
    SAMPLE=$(echo ${i} | sed "s/_L001_R1_\CLEANEST\.fastq//")
    echo ${SAMPLE}_L001_R1_CLEANEST.fastq ${SAMPLE}_L001_R2_CLEANEST.fastq
    
     /opt/anaconda3/bin/megahit -1 ${SAMPLE}_L001_R1_CLEANEST.fastq -2 ${SAMPLE}_L001_R2_CLEANEST.fastq -r ${SAMPLE}_L001_merged.fastq -t 12 -o ./megahit_${SAMPLE}_assembly_${today}
    
done

# MEGAHIT assembly tips
# for ultra complex metagenomics data such as soil, a larger kmin, say 27, is recommended to reduce the complexity of the de Bruijn graph.
### Quality trimming is also recommended
# --min-count 2 ----> (kmin+1)-mer with multiplicity lower than d (default 2, specified by --min-count option) will be discarded;
### recommend using the default value 2 for metagenomics assembly

## MORE MEGAHIT TIPS: https://sites.google.com/site/wiki4metagenomics/tools/assembly/megahit


#/opt/anaconda3/bin/megahit ---- path for megahit program; for running on my computer
