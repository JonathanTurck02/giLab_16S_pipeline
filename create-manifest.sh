## Step 1: Create list of file names:
# Remove file_names.txt if it already exists
rm -f file_names.txt
touch file_names.txt
ls *.gz > file_names.txt

## Step 2: (Optional) Ordering of samples ids in manifest file
# order by number in first part of the name (eg by 6 in R6_S1_L001_R1_001.fastq.gz):
# R6 is first column (-k1) when the delimiter is _ (-t"_")
# -n for sorting numerically
# 1.2-1.4 is for range of characters in first column to be used for sorting
# 1.2 for second character in 1st column
sort -t"_" -n -k1.2,1.4 file_names.txt > file_names_sorted.txt
#sort -t"_" -n \-k{$orderBy_col}.{$orderBy_char_range_lower},{$orderBy_col}.{$orderBy_char_range_upper}

## Use file_names.txt instead of file_names_sorted.txt, for all following steps if no sorting is needed.
## Step 3: Create list of Sample IDs:
# Remove file_names.txt if it already exists
rm -f sample_ids.txt 
touch sample_ids.txt
# Change this depending on how the Sample IDs are to be extracted from names:
cut -d_ -f1 file_names_sorted.txt > sample_id.txt

## Step 4: Create list of file paths:
rm -f abs_filepath.txt
touch abs_filepath.txt
for i in $(cat file_names_sorted.txt); do echo "$(pwd -P)/$i" >> abs_filepath.txt ; done
# Remove all spaces in file paths
sed -i -e 's/ /\\ /g' abs_filepath.txt

## Step 5: Create a list of directions:
rm -f direction.txt
touch direction.txt
# Assuming R1 and R2 in the name do not represent anything other than read direction
for i in $(cat file_names_sorted.txt)
do
  case $i in
    *_R1_*) echo "forward"  >> direction.txt ;;
    *_R2_*) echo "reverse" >> direction.txt ;;
  esac
done

## Step 6: Join Sample ID, file paths and direction into single file called manifest
rm -f manifest.txt
touch manifest.txt
echo "sample-id,absolute-filepath,direction" > manifest.txt
paste -d, sample_id.txt abs_filepath.txt direction.txt >> manifest.txt

## Step 7: Clean up
rm -f file_names.txt sample_ids.txt abs_filepath.txt direction.txt
