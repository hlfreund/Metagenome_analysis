#!/bin/sh

# Need to look through CheckM results to examine completeness and contamination of (assembled) genome bins
# Separate out bins based on completeness and contamination
# Should take high, med, and low quality bins and re-bin them to try and achieve better completeness

today=$(date "+%m.%d.%y") # date is the command to get today's date, and the "+%m_%d_%y" will print it in month_day_year format

for i in $(ls *_checkm_qa_11.21.20.tsv); # change to your output file names from when you ran CheckM
do
    SAMPLE=$(echo $i | sed "s/_checkm_qa_11.21.20.tsv//")

    echo "${SAMPLE}: separating bins based on quality -- CheckM results"
    
    sed -i 's/_contigs.fasta.metabat-bins-_-t_4_-m_1500./_bin_/g' ${i}
    
    awk -F '\t' 'BEGIN {OFS="\t"} { if ( NR == 1 ) print "Sample_ID", "Bin_Num" ,"Taxa_Level", "Marker_Lineage", "Lineage_ID", "Genome_Num", "Completeness", "Contamination", "Strain_Heterogeneity", "GC_Content"; else if ($6 >=95 && $7 < 5) print $1,$2,$3,$6,$7,$8,$19}' ${i} | sed 's/ /\t/g' | sed 's/_bin/\tBin/g' | sed 's/__/\t/g' > ${SAMPLE}_best_quality.tsv
    ## BEST quality = > 95% complete, < 5% contamination

    awk -F '\t' 'BEGIN {OFS="\t"} { if ( NR == 1 ) print "Sample_ID", "Bin_Num" ,"Taxa_Level", "Marker_Lineage", "Lineage_ID", "Genome_Num", "Completeness", "Contamination", "Strain_Heterogeneity", "GC_Content"; else if ($6 >=90 && $6 <95 && $7 < 5) print $1,$2,$3,$6,$7,$8,$19}' ${i} | sed 's/ /\t/g' | sed 's/_bin/\tBin/g' | sed 's/__/\t/g'> ${SAMPLE}_high_quality.tsv
    ## HIGH quality = > 90% complete,  < 5% contamination

    awk -F '\t' 'BEGIN {OFS="\t"} { if ( NR == 1 ) print "Sample_ID", "Bin_Num" ,"Taxa_Level", "Marker_Lineage", "Lineage_ID", "Genome_Num", "Completeness", "Contamination", "Strain_Heterogeneity", "GC_Content"; else if ($6 >=50 && $6 <90 && $7 < 10) print $1,$2,$3,$6,$7,$8,$19}' ${i} | sed 's/ /\t/g' | sed 's/_bin/\tBin/g' | sed 's/__/\t/g' > ${SAMPLE}_med_quality.tsv
    ## MED quality = > 50% complete,  < 10% contamination

    awk -F '\t' 'BEGIN {OFS="\t"} { if ( NR == 1 ) print "Sample_ID", "Bin_Num" ,"Taxa_Level", "Marker_Lineage", "Lineage_ID", "Genome_Num", "Completeness", "Contamination", "Strain_Heterogeneity", "GC_Content"; else if ($6 <50 && $6 >0 && $7 < 10) print $1,$2,$3,$6,$7,$8,$19}' ${i} | sed 's/ /\t/g' | sed 's/_bin/\tBin/g' | sed 's/__/\t/g' > ${SAMPLE}_low_quality.tsv
    ## LOW quality = < 50% complete,  < 10% contamination
done

## Thresholds taken from the following papers:
# Chen, L. X., Anantharaman, K., Shaiber, A., Murat Eren, A., & Banfield, J. F. (2020). Accurate and complete genomes from metagenomes. Genome Research. Cold Spring Harbor Laboratory Press. https://doi.org/10.1101/gr.258640.119
# Bowers, R., Kyrpides, N., Stepanauskas, R. et al. Minimum information about a single amplified genome (MISAG) and a metagenome-assembled genome (MIMAG) of bacteria and archaea. Nat Biotechnol 35, 725–731 (2017). https://doi.org/10.1038/nbt.3893

# AWK notes
# -F ' ' == field separator of input doc is a space
# NR == 1 == if first line is 1, do _____
