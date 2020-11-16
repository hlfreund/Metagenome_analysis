#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4 # must match the # of threads (-t #)
##SBATCH --mem-per-cpu=500G # * if threading, do not let this line run (use ##). Cannot ask for too much memory per cpu!
#SBATCH --time=10-00:00:00     # 7 days, 0 hrs
#SBATCH --output=spades_mgm_assembly_11.13.20.stdout
#SBATCH --mail-user=hfreu002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name="Assembling MGMs with Spades 11/13/2020"
#SBATCH -p highmem
# you can use any of the following: intel, batch, highmem, gpu

cd /bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/ # change to your desired directory

Path="/bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/" # initiate your path for later

today=$(date "+%m.%d.%y") # date is the command to get today's date, and the "+%m_%d_%y" will print it in month_day_year format

module load SPAdes/3.14.1 # load the module on your computing cluster system (ignore this if running locally)


for i in *_R1_normalized_error_corrected.fastq.gz;
do
    SAMPLE=$(echo ${i} | sed "s/_L001_R1_normalized_error_corrected.fastq.gz//")
    echo ${SAMPLE}_L001_R1 ${SAMPLE}_L001_R2 ${SAMPLE}_normalized_merged ${SAMPLE}_L001_R_unpaired
    
    if [[ ! -d ${Path}/${SAMPLE}_assembly_SPades_${today} ]]; then

        metaspades.py -1 ${SAMPLE}_L001_R1_normalized_error_corrected.fastq.gz -2 ${SAMPLE}_L001_R2_normalized_error_corrected.fastq.gz --merged ${SAMPLE}_normalized_merged_error_corrected.fastq.gz -s ${SAMPLE}_L001_R_unpaired_error_corrected.fastq.gz -o ${SAMPLE}_assembly_SPades_${today} --meta -t 4 --only-assembler
    
        mv ${Path}/${SAMPLE}_assembly_SPades_${today}/scaffolds.fasta ${Path}/${SAMPLE}_assembly_SPades_${today}/${SAMPLE}_scaffolds.fasta
    
        cp ${Path}/${SAMPLE}_assembly_SPades_${today}/${SAMPLE}_scaffolds.fasta ${Path}/
    #echo -e "Finished \aassembling ${SAMPLE}_L001_R1 ${SAMPLE}_L001_R2"
    fi
done

echo -e "Finished \aall assemblies with SPades"


## Spades assembly - https://github.com/ablab/spades#meta ; https://cab.spbu.ru/files/release3.12.0/manual.html#meta
## Notes for Spades...
## spades.py -1 read1.fq -2 read2.fq --merged merged.fq -s unpaired.fq -o spades_mgm_assemblies_${today}
## ^^^ -s is the flag to indicate unpaired reads (output from things that could not merge OR were found unpaired after error correction (using merged and unmerged reads for error correction)
## output_directory/scaffolds.fasta – resulting scaffolds (recommended for use as resulting sequences) ****

## Spades Output
#The full list of <output_dir> content is presented below:

#scaffolds.fasta – resulting scaffolds (recommended for use as resulting sequences) *****
#contigs.fasta – resulting contigs
#assembly_graph.fastg – assembly graph [To view FASTG and GFA files they recommend to use Bandage visualization tool]
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
#
# From https://cab.spbu.ru/files/release3.14.1/manual.html#sec3.5
#<output_dir>/corrected/ directory contains reads corrected by BayesHammer in *.fastq.gz files; if compression is disabled, reads are stored in uncompressed *.fastq files
#<output_dir>/scaffolds.fasta contains resulting scaffolds (recommended for use as resulting sequences)
#<output_dir>/contigs.fasta contains resulting contigs
#<output_dir>/assembly_graph_with_scaffolds.gfa contains SPAdes assembly graph and scaffolds paths in GFA 1.0 format
#<output_dir>/assembly_graph.fastg contains SPAdes assembly graph in FASTG format
#^^^ Note that sequences stored in assembly_graph.fastg correspond to contigs before repeat resolution (edges of the assembly graph). Paths corresponding to contigs after repeat resolution (scaffolding) are stored in contigs.paths (scaffolds.paths) in the format accepted by Bandage (see Bandage wiki for details)
#<output_dir>/contigs.paths contains paths in the assembly graph corresponding to contigs.fasta (see details below)
#<output_dir>/scaffolds.paths contains paths in the assembly graph corresponding to scaffolds.fasta (see details below)

## Spades output FASTA format:
#>NODE_3_length_237403_cov_243.207
# Here 3 is the number of the contig/scaffold, 237403 is the sequence length in nucleotides and 243.207 is the k-mer coverage for the last (largest) k value used. Note that the k-mer coverage is always lower than the read (per-base) coverage.
## HPCC (Cluster systems) note
##SBATCH --mem-per-cpu=500G # --mem=900gb --> how to request for total allocation of mem rather than mem per cpu; include in job submission command

