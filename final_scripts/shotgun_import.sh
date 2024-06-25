# shotgun_import.sh
# AUTHOR: Jonathan Turck
# MODIFIED: 4/16/2024
# COMPATIBLE QIIME2 VERSION: 2024.2-shotgun

# load modules
module load Anaconda3/2023.07-2
source activate /sw/hprc/sw/Anaconda3/2023.07-2/envs/qiime2-2024.2-shotgun

# Import Sequences
qiime tools import \
 --input-path taxatable-filtered-absolute.biom \
 --type FeatureTable[Frequency] \
 --input-format BIOMV100Format \
 --output-path filtered-feature-table.qza

# Generate counts_summary
qiime feature-table summarize \
  --i-table filtered-feature-table.qza \
  --m-sample-metadata-file ${mappingFile} \
  --o-visualization filtered-feature-table-summ.qzv

qiime tools export \
  --input-path filtered-feature-table.qza \
  --output-path counts_summary

biom summarize-table \
  -i counts_summary/feature-table.biom \
  -o counts_summary/feature-table-summ.txt

#Convery original biom table to BiomV210 format OTU table
biom convert \
-i taxatable-filtered-absolute.biom \
-o taxatable.biom --table-type="OTU table" --to-hdf5

#Extract taxonomy from the original file
qiime tools import \
  --input-path  taxatable.biom \
  --output-path taxonomy.qza \
  --input-format BIOMV210Format \
  --type "FeatureData[Taxonomy]"
  
# Edit shotgun_downstream.sh with USER INPUTS
# Run shotgun_downstream.sh
sbatch BETA_shotgun_downstream.sh