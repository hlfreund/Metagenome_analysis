#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8 # must match the # of threads (-t #)
##SBATCH --mem-per-cpu=900G # * if threading, do not let this line run (use ##). Cannot ask for too much memory per cpu!
#SBATCH --time=10-00:00:00     # 10 days, 0 hrs
#SBATCH --output=Check_QA_assembled_contigs_11.21.20.stdout
#SBATCH --mail-user=hfreu002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name="Check_QA_assembled_contigs_11.21.2020"
#SBATCH -p highmem
# you can use any of the following: intel, batch, highmem, gpu

cd /bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/ # change to your desired directory

Path="/bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/" # initiate your path for later

today=$(date "+%m.%d.%y") # date is the command to get today's date, and the "+%m_%d_%y" will print it in month_day_year format

module load checkm/1.1.3 # load the module on your computing cluster system (ignore this if running locally)
#
checkm taxon_set domain Bacteria Bacteria_marker_file
checkm taxon_set domain Archaea Archaea_marker_file

for i in *_contigs.fasta;
do
    SAMPLE=$(echo ${i} | sed "s/_contigs.fasta//")
    echo ${SAMPLE}
    if [[ ! -d ${Path}/${SAMPLE}_checkm_lineage_${today} ]]; then
        checkm lineage_wf -t 8 -x fa ./${SAMPLE}_bins_metabat ./${SAMPLE}_checkm_lineage_${today} -f ${SAMPLE}_checkm_lineage_results_${today}.txt --tab_table
        ## checkm lineage_wf -t {#threads} -x {file format, aka fa} {BIN_DIRECTORY} {OUTPUT_DIRECTORY} -f {output file} --tab_tablels -
    fi
    
    if [[ ! -f ${Path}/${SAMPLE}_checkm_qa_${today}.tsv ]]; then
        checkm qa -o 2 -f ./${SAMPLE}_checkm_qa_${today}.tsv --tab_table ./${SAMPLE}_checkm_lineage_11.20.20/lineage.ms ./${SAMPLE}_checkm_lineage_11.20.20/
        # checkm qa --output_format 2 -f {output_file} --table_table {/path/to/marker/file(either lineage.ms if used checkm lineage_wf, or a taxon specific ms used for analyze command} {/path/to/checkm_lineage (or taxonomy) output}
    
    if [[ ! -f ${Path}/${SAMPLE}_checkm_coverage_${today}.tsv ]]; then
        checkm coverage -x fa -q ./${SAMPLE}_bins_metabat ${SAMPLE}_checkm_coverage_${today}.tsv ${SAMPLE}_sorted.bam
        
    fi
    
    if [[ ! -d ${Path}/./${SAMPLE}_bacteria_marker_bins ]] && [[ ! -d ${Path}/./${SAMPLE}_archaea_marker_bins ]]; then
        checkm analyze Bacteria_marker_file ./${SAMPLE}_bins_metabat -x fa -t 4 ./${SAMPLE}_bacteria_marker_bins
        checkm qa Bacteria_marker_file ./${SAMPLE}_bacteria_marker_bins -o 2 -f ${SAMPLE}_bacteria_marker_results.txt --tab_table
    
        checkm analyze Archaea_marker_file ./${SAMPLE}_bins_metabat -x fa -t 4 ./${SAMPLE}_archaea_marker_bins
        checkm qa Archaea_marker_file ./${SAMPLE}_archaea_marker_bins -o 2 -f ${SAMPLE}_archaea_marker_results.txt --tab_table
    fi
    # checkm analyze <marker file> <bin folder> <output folder>

    
    #checkm profile ${SAMPLE}_checkm_coverage_${today}.tsv

    ## lineage_wf assess completeness & contamination of genome bins w/ lineage-sepcific marker sets
    
    #checkm taxonomy_wf domain Bacteria ./${SAMPLE}_bins_metabat ./${SAMPLE}_bacteria_marker_bins
    ## taxonomy_wf analyzes all genome bins with same marker set
done

## Info on CheckM
## https://github.com/Ecogenomics/CheckM/wiki/Workflows#lineage-specific-workflow
## https://github.com/Ecogenomics/CheckM/wiki/
## https://www.hadriengourle.com/tutorials/meta_assembly/ -- using it
## https://bitbucket.org/berkeleylab/metabat/wiki/Best%20Binning%20Practices -- using it after MetaBAT
