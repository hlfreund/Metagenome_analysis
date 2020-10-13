#!/bin/sh

## use the output from decontamination step as input here
## input file will be R1_001_clean1 or R2_001_clean1

for i in *_R1_001.fastq;
do
    SAMPLE=$(echo ${i} | sed "s/_R1_\001\.fastq//")
    echo ${SAMPLE}_R1_001.fastq ${SAMPLE}_R2_001.fastq
    /Volumes/HLF_SSD/Aronson_Lab_Data/bbmap/bbduk.sh -Xmx1g in1=${SAMPLE}_R1_001.fastq in2=${SAMPLE}_R2_001.fastq out1=${SAMPLE}_R1_CLEANEST.fastq out2=${SAMPLE}_R2_CLEANEST.fastq rcomp=t ktrim=r k=23 mink=11 ref=/Volumes/HLF_SSD/Aronson_Lab_Data/bbmap/resources/truseq.fa.gz literal=AATGATACGGCGACCACCGAGATCTACACNNNNNNNNACACTCTTTCCCTACACGACGCTCTTCCGATCT,CAAGCAGAAGACGGCATACGAGATNNNNNNNNGTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT hdist=1 maq=10 minlen=51 trimq=20 tpe tbo

done

#cutadapt --pair-adapters -b ACTGCGAA -B TTCGCAGT -o ${SAMPLE}_R1_001_trim.fastq -p ${SAMPLE}_R2_001_trim.fastq  ${SAMPLE}_R1_001.fastq ${SAMPLE}_R2_001.fastq

#/Volumes/HLF_SSD/Aronson_Lab_Data/bbmap/bbduk.sh in1=/Volumes/HLF_SSD/Aronson_Lab_Data/SaltonSea_POW/EA_Pool-POW_1-1a_S28_L001_R1_001_clean1.fastq in2=EA_Pool-POW_1-1a_S28_L001_R2_001_clean1.fastq out1=/Volumes/HLF_SSD/Aronson_Lab_Data/SaltonSea_POW/EA_Pool-POW_1-1a_S28_L001_R1_001_clean.fq out2=/Volumes/HLF_SSD/Aronson_Lab_Data/SaltonSea_POW/EA_Pool-POW_1-1a_S28_L001_R2_001_clean.fq  literal=ACTGCGAA,TTCGCAGT rcomp=t ktrim=r k=23 mink=11 hdist=1 maq=10 minlen=51 trimq=20 tpe tbo

# ref ---> file provided by bbduk that holds collection of Illumina TruSeq adapters
# literal=(sequence here) ---> literal adapter sequences to remove; "N" represents any base -- in this case, they are indexes within the adapters
# rcomp=t ---> Rcomp looks for kmers and their reverse-complements, rather than just forward kmer, if set to true
# ktrim=r ---> “ktrim=r” is for right-trimming (3′ adapters)
# k=23 ---> look for kmer that is 23 bp long
# mink=11 ---> in addition to kmers of x length, look for shorter kmers with lengths 23 to 11 (in this case)
# maq=10 ---> This will discard reads with average quality below 10
# hdist=1 ---> hamming distance of 1
# mlf=50 ---> (minlengthfraction=50) would discard reads under 50% of their original length after trimming
# trimq=10 ---> quality-trim to Q10 using the Phred algorithm, which is more accurate than naive trimming.
# qtrim=r ---> means it will quality trim the right side only
# tpe ---> which specifies to trim both reads to the same length
# tbo ---> which specifies to also trim adapters based on pair overlap detection using BBMerge (which does not require known adapter sequences)

# more on hdist...
# A 4.6Mbp genome like E.coli contains around 4.6 million unique kmers. If a hamming distance is used, such as hdist=1, then the number of kmers stored will be
# multiplied by 1+(3*k)^hdist. So, for E.coli with K=31 and hdist=0, there are 4554207 kmers stored, using around 140MB, taking about 0.5 seconds; with
# hdist=1, there are 427998710 kmers stored (94 times as many), using 15GB, and taking 104 seconds
# BBDuk needs around 20 bytes per kmer

# BBDuk supports kmers of length 1-31. The longer a kmer, the high the specificity
# Note that it is impossible to do kmer matching for reference sequences that are shorter than K.
# When kmer filtering, you can specify a kmer length greater than 31 (such as k=40) for even higher specificity.
# For k=40, BBDuk will consider a read to match the reference if there are 10 consecutive 31-mer matches. This is not exactly the same as actually matching 40-mers, but is very similar.
