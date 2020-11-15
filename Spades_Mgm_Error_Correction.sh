#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4 # must match the # of threads (-t #)
##SBATCH --mem-per-cpu=200G # * if threading, do not let this line run (use ##). Cannot ask for too much memory per cpu!
#SBATCH --time=7-00:00:00     # 7 days, 0 hrs
#SBATCH --output=Spades_mgm_error_correction_11.9.20.stdout
#SBATCH --mail-user=hfreu002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name="Error correcting clean reads with Spades 11/9/2020"
#SBATCH -p highmem
# you can use any of the following: intel, batch, highmem, gpu

cd /bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/

Path="/bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/"

today=$(date "+%m.%d.%y") # date is the command to get today's date, and the "+%m_%d_%y" will print it in month_day_year format

module load SPAdes/3.14.1

for i in *_R1_normalized.fastq;
do
    SAMPLE=$(echo ${i} | sed "s/_L001_R1_normalized.fastq//")
    echo ${SAMPLE}
    
    spades.py -1 ${SAMPLE}_L001_R1_normalized.fastq -2 ${SAMPLE}_L001_R2_normalized.fastq --merged ${SAMPLE}_normalized_merged.fastq -o spades_error_corrected_reads_${today} -t 4 --meta --only-error-correction
    
    #echo -e "Finished \aerror correction with ${SAMPLE}_L001_R1 ${SAMPLE}_L001_R2"

done

cd /bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/spades_error_corrected_reads_${today}/corrected/

for i in *.fastq.gz;
do

    mv ${SAMPLE}_L001_R1_normalized.00.0_0.cor.fastq.gz ${SAMPLE}_L001_R1_normalized_error_corrected.fastq.gz
    mv ${SAMPLE}_L001_R2_normalized.00.0_0.cor.fastq.gz ${SAMPLE}_L001_R2_normalized_error_corrected.fastq.gz
    mv ${SAMPLE}_normalized_merged.00.0_1.cor.fastq.gz ${SAMPLE}_normalized_merged_error_corrected.fastq.gz
    mv ${SAMPLE}_L001_R_unpaired.00.0_0.cor.fastq.gz ${SAMPLE}_L001_R_unpaired_error_corrected.fastq.gz
    cp *.fastq.gz ${Path}/
done

echo -e "Finished \aerror correction on mgm reads with SPades"

## Spades assembly - https://github.com/ablab/spades#meta
## Notes for Spades...
## spades.py -1 read1.fq -2 read2.fq --merged merged.fq -o spades_test <<< -s is the flag to indicate merged reads as a "library"
## Error corrected sequences wil be found in output_directory/corrected/ – files from read error correction

## Spades Output
#The full list of <output_dir> content is presented below:

#scaffolds.fasta – resulting scaffolds (recommended for use as resulting sequences) *****
#contigs.fasta – resulting contigs
#assembly_graph.fastg – assembly graph
#contigs.paths – contigs paths in the assembly graph
#scaffolds.paths – scaffolds paths in the assembly graph
#before_rr.fasta – contigs before repeat resolution
#corrected/ – files from read error correction
#   configs/ – configuration files for read error correction
#   corrected.yaml – internal configuration file
#   Output files with corrected reads
#params.txt – information about SPAdes parameters in this run
#spades.log – SPAdes log
#dataset.info – internal configuration file
#input_dataset.yaml – internal YAML data set file
#K<##>/– directory containing intermediate files from the run with K=<##>. These files should not be used as assembly results; use resulting contigs/scaffolds in files mentioned above.

## HPCC (Cluster systems) note
##SBATCH --mem-per-cpu=500G # --mem=900gb --> how to request for total allocation of mem rather than mem per cpu; include in job submission command

for i in ${Path}/spades_error_corrected_reads_11.13.20/corrected/*.fastq.gz;
do
    cp *.fastq.gz ${Path}/
done
