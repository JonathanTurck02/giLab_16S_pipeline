#!/bin/bash

## Step 1: Create list of file names:
rm -f file_names.txt
touch file_names.txt
ls *.fastq.gz > file_names.txt

## Step 2: (Optional) Ordering of samples ids in manifest file
sort -t"_" -n -k1.2,1.4 file_names.txt > file_names_sorted.txt

## Step 3: Create list of Sample IDs:
rm -f sample_ids.txt 
touch sample_ids.txt
cut -d_ -f1 file_names_sorted.txt | uniq > sample_ids.txt

## Step 4: Create lists of forward and reverse file paths for each sample ID:
for sample_id in $(cat sample_ids.txt)
do
    grep "$sample_id" file_names_sorted.txt | grep "_R1_" > "${sample_id}_R1.txt"
    grep "$sample_id" file_names_sorted.txt | grep "_R2_" > "${sample_id}_R2.txt"
done

## Step 5: Create the manifest file
rm -f manifest.txt
touch manifest.txt
echo -e "sample-id\tforward-absolute-filepath\treverse-absolute-filepath" > manifest.txt
for sample_id in $(cat sample_ids.txt)
do
    forward_filepath=$(cat "${sample_id}_R1.txt")
    reverse_filepath=$(cat "${sample_id}_R2.txt")
    echo -e "$sample_id\t$(pwd -P)/$forward_filepath\t$(pwd -P)/$reverse_filepath" >> manifest.txt
done

## Step 6: Clean up
rm -f file_names.txt file_names_sorted.txt sample_ids.txt *_R1.txt *_R2.txt


