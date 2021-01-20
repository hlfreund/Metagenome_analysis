# Metagenome analyses!

This is a repository in progress!

These are scripts I use to analyze **shotgun metagenomes**. These scripts can be adapted for amplicon reads, single end reads, etc.

Currently I am using a high performance computing cluster that uses a Slurm manager. 

### Trimming adapters & indexes from reads

- bbduk_loop.sh

### Normalize read depth of coverage

- bbnorm_loop.sh

### Merging reads

- bbmerge_loop.sh

### Read Error Correction

- Spades_Mgm_Error_Correction.sh

### Metagenome Assembly

- Spades_mgm_Assembly.sh
  - can be used for non-metagenomic genome assembly by changing metaspades.py to spades.py and removing the --meta argument
- megahit_loop_hpcc.sh  (for running on Slurm cluster system)
- megahit_loop_local.sh (for running locally) 
  - both megahit scripts could be used for non-metagenomic genome assembly, but please refer to their manuals for available arguments & syntax.
* Currently metaSPADES can only handle one library at a time, whereas megahit can do co-assembly

### Map Reads to Assembly

- bwa_map_to_contigs.sh
  - creates SAM file which is then converted to BAM file with Samtools
  - After indexing and sorting the BAM file, this script uses Samtools to create stats about alignment + mapping

### Contig Binning with MetaBAT2

- metaBAT_contig_binning_loop_hpcc.sh (for running on Slurm cluster system)
- metaBAT_contig_binning_loop.sh (for running locally)

### Check Assembly Quality

- Checkm_QA_MAGs.sh
  - Check genome completeness, contamination & basic taxonomy
- metaQUAST_Compare_mgm_Assemblies.sh
  - Compare genome assemblies, completeness, contamination, & basic taxonomy
- Parse_QA_Results.sh
    - separate genome bins based on completeness and contamination percentages
- Examine_MGM_Quality.R
    - visually examine genome bins based on completeness, contamination, and other stats (based on CheckM output)

### Gene Prediction & Annotation

- Taxonomic Annotation
    - TBD
- Functional Annotation
    - TBD
    
### Reconstruct SSU rRNA genes from metagenome short reads
- PhyloFlash_16S_ID.sh (for running on cluster system)
    - uses metagenome short reads to assemble into possible SSU rRNA genes (16S, 18S) for taxnomic identification

