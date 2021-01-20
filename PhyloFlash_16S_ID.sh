#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=500G
#SBATCH --time=5-00:00:00     # 5 days
#SBATCH --output=your_output_file_date.stdout
#SBATCH --mail-user=youremail@gmail.com
#SBATCH --mail-type=ALL
#SBATCH --job-name="Job title and date here"
#SBATCH -p highmem
# you can use any of the following: intel, batch, highmem, gpu

cd your/path/here ### change to your currenty directory for sanity's sake

today=$(date "+%m.%d.%y") # date is the command to get today's date, and the "+%m_%d_%y" will print it in month_day_year format

# load modules you need for phyloflash (programs recruited within phyloflash)
module unload miniconda2
module load miniconda3
module load funannotate
module load perl
module load BBMap/38.86
module load vsearch
module load SPAdes/3.14.1
module load bedtools
module load mafft
module load barrnap
module load phyloFlash/3.3b4

## create PhyloFlash database with locally downloaded databases (Silva, UniVec)
## for database creation, visit this link https://hrgv.github.io/phyloFlash/install.html and see step 4.Setting up the reference database
phyloFlash_makedb.pl --univec_file path/to/file --silva_file path/to/file.1_SSURef_NR99_tax_silva_trunc.fasta.gz

mv 138.1 138_1db #rename database so it's compatible with PhyloFlash and has a name that sort of makes sense -- using Silva 138.1 version
## * cannot name db with the name "SILVA" due to the db file having the same name -- program uses that to ID file, so the actual db name has to be different

path=/path/to/where/sequences/are/stored # path to current directory
path2=${path}/PhyloFlash_Results # path to directory I want results stored

for i in $path/*_R1_CLEANEST.fastq;
do
    SAMPLE=$(echo ${i} | sed 's/.*Pool-\(.*\)/\1/' | sed 's/_L001_R1_CLEANEST.fastq//') ## edit files to grab sample names - can adjust for your own sample file names
    echo ${SAMPLE} "Finding 16S regions in trimmed, raw metagenome reads"
    
    mkdir ${SAMPLE}_PhyloFlash_Output_${today} # make directory for specific sample results
    cd ./${SAMPLE}_PhyloFlash_Output_${today}
    
    phyloFlash.pl -lib Lib_phyflash -readlength 150 -CPUs 4 -poscov -log -dbhome $path2/138_1db -read1 $path/EA_Pool-${SAMPLE}_L001_R1_CLEANEST.fastq -read2 $path/EA_Pool-${SAMPLE}_L001_R2_CLEANEST.fastq
    
    rename -v Lib_phyflash ${SAMPLE}_lib * #rename all files to include sample name in file name; must have rename command installed
    
    cd $path2

done



## PhyloFlash Notes
# -log - writes status messages to log file
# -dbhome DIR Directory containing phyloFlash reference databases, prepared with phyloFlash_makedb.pl. If not specified, phyloFlash will check for an environment variable $PHYLOFLASH_DBHOME, then look in the current directory, the home directory, and the directory where the phyloFlash.pl script is located, for a suitable database directory containing the necessary files.
# - If you think phyloFlash is not detecting a certain organism that is very distant from the known SSU rRNA sequences please try lowering the minimum sequence identity for a mapping hit by using e.g. -id 0.63
# The name of the Fasta file should begin with SILVA_{DBNAME}_ where DBNAME is the name of the database (e.g. CustomDB), and will also be the name of the output folder containing the formatted database files
## PhyloFlash Output File Descriptions
#Report files
#These are the main human-readable output from phyloFlash.
#
#LIBNAME.phyloFlash.html phyloFlash report file in HTML format, with a report on the taxonomic composition of SSU rRNA reads, quality metrics for the library, and affiliation of the reconstructed/assembled full-length sequences.
#LIBNAME.phyloFlash plain text file version of the report

#Unassembled sequence files
#Reads that map to the reference database are extracted to these files in Fastq format
#
#LIBNAME.test_F.fq.gz.SSU.1.fq the filtered SSU reads and their paired read, forward read file
#LIBNAME.test_F.fq.gz.SSU.2.fq the filtered SSU reads and their paired read, reverse read file

#Assembled/reconstructed sequence files
#Assembled or reconstructed full-length SSU rRNA reads are output unless the -skip_spades or -skip_emirge options are used.
#
#LIBNAME.spades_rRNAs.final.fasta assembled OTUs from SPAdes with phyloFlash simplified headers
#
#LIBNAME.emirge.final.phyloFlash.notmatched.fa a fasta file with the reconstructed SSU sequences with no significant hit in the provided SSU database
#LIBNAME.emirge.final.fa a fasta file with the Emirge reconstructed SSU OTUs
#LIBNAME.emirge.final.phyloFlash.dbhits.fa a fasta file with the best hits for the reconstructed SSU sequences in the provided SSU database
#
#LIBNAME.all.final.fasta All assembled and reconstructed sequences from SPAdes and/or EMIRGE in a single file
#LIBNAME.all.final.phyloFlash.dbhits.fa
#LIBNAME.all.final.phyloFlash.notmatched.fa
#
#LIBNAME.all.dbhits.NR97.fa Reference sequences from database with hits from the supplied reads, clustered at 97% identity

#Alignments
#LIBNAME.SSU.collection.alignment.fasta an aligned multifasta of all the predicted OTUs and the references
#LIBNAME.SSU.collection.fasta a multifasta of all the predicted OTUs and the references
#LIBNAME.SSU.collection.fasta.tree an NJ tree of the mafft alignment of all the predicted OTUs and the references. PDF and PNG versions are created for the HTML report if the -html option is set
#Other statistics

#LIBNAME.inserthistogram Histogram of detected insert sizes in tab-separated format, if paired-end reads were input. PDF and PNG versions are created for the HTML report if the -html option is set
#LIBNAME.idhistogram Histogram of the % identity of reads vs. reference database sequences, in tab-separated format. PDF and PNG versions are created for the HTML report if the -html option is set
#LIBNAME.phyloFlash.NTUabundance.csv the list of uniqe higher level taxa (e.g. orders for bacteria) in the order of their appearance

#LIBNAME.scaffolds.arch.gff 16S rRNA gene predictions for assembled OTUs based on archaeal SSU rRNA hmm profile
#LIBNAME.scaffolds.bac.gff 16S rRNA gene predictions for assembled OTUs based on bacterial SSU rRNA hmm profile
#LIBNAME.scaffolds.euk.gff 18S rRNA gene predictions for assembled OTUs based on eukaryote SSU rRNA hmm profile

#CSV files used for multiple-sample comparison *** aka what to import into R!
#These files are used by the phyloFlash_heatmap.R script if you wish to compare multiple samples by their taxonomic composition.
#LIBNAME.phyloFlash.NTUabundance.csv
#LIBNAME.phyloFlash.report.csv
