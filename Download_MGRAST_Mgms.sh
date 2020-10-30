#!/bin/sh

for mgm in $(cat MGM_ID_List1.txt) #read in list of your metagenome IDs
do

curl -o "$mgm"_650.txt http://api.metagenomics.anl.gov/1/download/"$mgm"?file=650.1 # download metagenome w/ annotatins from MG-RAST

    while read md5id #save metagenome IDs and md5 ids in separate file
    do
    cut -f 2 > "$mgm"_md5id_list.txt
    echo
    done < "$mgm"_650.txt
done

# to find the file types that are downloadable from MG-RAST, go here https://help.mg-rast.org/user_manual.html
# specifically the section "The downloadable files for each data set"
# 650 file : Packaged results of the blat search against all the protein databases with MD5 value of the database sequence hit followed by sequence or cluster ID, similarity information, functional annotation, organism, database name.
# 650.superblat.expand.protein file contains the following: md5 (id for database hit), feature ID for singletons or clsuter ID for query, alignment % identity, alignment length, E-value, protien function label, and species name associated with best protein hit
## Multiple types of 650 files

## For more assistance, visit this link https://angus.readthedocs.io/en/2014/howe-mgrast.html




