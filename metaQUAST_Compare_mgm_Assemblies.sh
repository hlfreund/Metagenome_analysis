#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4 # must match the # of threads (-t #)
##SBATCH --mem-per-cpu=700G # * if threading, do not let this line run (use ##). Cannot ask for too much memory per cpu!
#SBATCH --time=8-00:00:00     # 8 days, 0 hrs
#SBATCH --output=Check_Assembly_Quality_metaquast_12.3.20.stdout
#SBATCH --mail-user=hfreu002@ucr.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name="Check_Assembly_Quality_metaquast_12.3.20"
#SBATCH -p highmem
# you can use any of the following: intel, batch, highmem, gpu

cd /bigdata/aronsonlab/shared/HannahFreund/HannahFTemp/

today=$(date "+%m.%d.%y") # date is the command to get today's date, and the "+%m_%d_%y" will print it in month_day_year format

module load QUAST/5.0.0-dev # ignore this and the sbatch commands if running this locally or not on a Slurm system

for i in *_contigs.fasta;
do
    SAMPLE=$(echo ${i} | sed "s/_contigs.fasta//")
    echo "Checking ${SAMPLE} assembled CONTIGS with metaQUAST ${today}"
    
    metaquast.py -t 4 -f -o ./${SAMPLE}_metaQUAST_contigs_${today} --gene-finding ${SAMPLE}_contigs.fasta
    # if using sam file...
    # python metaquast.py -t 4 --glimmer -o ./${SAMPLE}_metaQUAST_contig_${today}--sam ${SAMPLE}_sam.sam ${SAMPLE}_contigs.fasta
    # if using bam file...
    # python metaquast.py -t 4 -f -o ./${SAMPLE}_metaQUAST_wbam_${today} --gene-finding --bam ${SAMPLE}_sorted.bam ${SAMPLE}_contigs.fasta
    
    echo "Checking ${SAMPLE} assembled scaffolds with metaQUAST ${today}"
    metaquast.py -t 4 -f -o ./${SAMPLE}_metaQUAST_scaffolds_${today} --gene-finding -s ${SAMPLE}_scaffolds.fasta
    

done

# metaQUAST notes...
# http://quast.sourceforge.net/docs/manual.html#faq_q15 | https://github.com/ablab/quast/
# --gene-finding == -f -- Enables gene finding. Affects performance, thus disabled by default. By default, we assume that the genome is prokaryotic, and apply GeneMarkS for gene finding. If the genome is eukaryotic, use --eukaryote option to enable GeneMark-ES instead. If the genome is fungal, use --fungus option to run GeneMark-ES in a special mode for analyzing fungal genomes. If it is a metagenome (you are running metaquast.py), MetaGeneMark is used. You can also force MetaGeneMark predictions with --mgm option described below.
# must have a sam or bam file for each contig or scaffold file included in command or else it won't run



