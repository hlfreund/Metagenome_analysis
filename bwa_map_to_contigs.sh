#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8 # must match the # of threads (-t #)
##SBATCH --mem-per-cpu=500G # * if threading, do not let this line run (use ##). Cannot ask for too much memory per cpu!
#SBATCH --time=7-00:00:00     # 7 days, 0 hrs
#SBATCH --output=BWA-MEM_map_reads_to_assembly_11.18.20.stdout
#SBATCH --mail-user=hfreu002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name="Mapping reads to assembled contigs with BWA-MEM 11/18/20"
##SBATCH -p highmem
# you can use any of the following: intel, batch, highmem, gpu

cd /bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/ # change to your desired directory

Path="/bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/" # initiate your path for later

today=$(date "+%m.%d.%y") # date is the command to get today's date, and the "+%m_%d_%y" will print it in month_day_year format

module load bwa-mem2/2.0
module load samtools/1.11
module load bwa/0.7.17


for i in *_contigs.fasta;
do
    SAMPLE=$(echo ${i} | sed "s/_contigs.fasta//")
    echo ${SAMPLE} " -- mapping reads to assembled contigs with BWA-MEM"
    
    ## First, build the index aka reference for mapping reads to
    bwa index ${SAMPLE}_contigs.fasta

    ### Map reads back using local alignment
    if [[ ! -f ${Path}/${SAMPLE}_contigs_aln_pe.sam ]]; then
    
        bwa mem ${SAMPLE}_contigs.fasta ${SAMPLE}_L001_R1_normalized_error_corrected.fastq.gz ${SAMPLE}_L001_R2_normalized_error_corrected.fastq.gz -t 8 > ${SAMPLE}_contigs_aln_pe.sam
        #bwa-mem2 mem -t 8 ${SAMPLE}_c_assembly ${SAMPLE}_L001_R1_normalized_error_corrected.fastq.gz ${SAMPLE}_L001_R2_normalized_error_corrected.fastq.gz > ${SAMPLE}_contigs_aln-pe.sam

    fi
       
done

for i in *_contigs_aln_pe.sam;
do
    SAMPLE=$(echo ${i} | sed "s/_contigs_aln_pe.sam//")
    echo ${SAMPLE} " -- switching SAM file to BAM file"
  
    ### Map reads back using local alignment
    if [[ -f ${Path}/${SAMPLE}_contigs_aln_pe.sam ]]; then
        
        ## Convert SAM file to BAM file with samtools
        samtools view -S -b ${SAMPLE}_contigs_aln_pe.sam > ${SAMPLE}_unsort_bwa.bam  ## views & converts SAM to BAM file
        samtools sort ${SAMPLE}_unsort_bwa.bam -o ${SAMPLE}_sorted.bam ## sorts BAM file; sort alignments by leftmost coordinates, or by read name when -n is used
        samtools index  ${SAMPLE}_sorted.bam ## indexes BAM file
        samtools flagstat -@ 8 -O tsv ${SAMPLE}_sorted.bam > ${SAMPLE}_sorted_stats.tsv
        samtools coverage  ${SAMPLE}_sorted.bam -o ${SAMPLE}_sorted_coverage.tsv
        samtools depth  ${SAMPLE}_sorted.bam -o ${SAMPLE}_sorted_depth.tsv

    fi
       
done
