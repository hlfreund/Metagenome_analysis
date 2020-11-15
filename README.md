# Metagenome analyses!

This is a repository in progress!

These are scripts I use to analyze **shotgun metagenomes**. These scripts can be adapted for amplicon reads, single end reads, etc.

Currently I am using a high performance computing cluster that uses a Slurm manager. 

#### Trimming adapters & indexes from reads

- bbduk_loop.sh

#### Normalize read depth of coverage

- bbnorm_loop.sh

#### Merging reads

- bbmerge_loop.sh

#### Read Error Correction

- Spades_Mgm_Error_Correction.sh

#### Metagenome Assembly

- Spades_mgm_Assembly.sh
  - can be used for non-metagenomic genome assembly by changing metaspades.py to spades.py and removing the --meta argument
- megahit_loop_local.sh (for running locally) 
- megahit_loop_hpcc.sh  (for running on cluster system)
  - both megahit scripts could be used for non-metagenomic genome assembly, but please refer to their manuals for available arguments & syntax.

