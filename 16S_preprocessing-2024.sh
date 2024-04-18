# This command list handles the initial importing and preprocessing of the data
# A manifest file must be created to handle this
# $case-sensitive input/output, please specify specific file name, path, or depth

# create manifest w/ create-manifest.sh

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path $manifest \
  --input-format PairedEndFastqManifestPhred33V2 \
  --output-path demux-paired-end.qza

# make visualization and view for quality control
qiime demux summarize \
  --i-data demux-paired-end.qza \
  --o-visualization demux-paired-end.qzv

# computationally intensive, run denoise with job
# dada2 performs quality filtering on its own

# visualize what denoise did, can change parameters of the denoise command to affect output
qiime metadata tabulate \
  --m-input-file table-dada2.qza \
  --o-visualization -dada2.qzv

# the consensus seems to not do any sort of rarefaction for differential abundance methods

# generate a read summary "feature-table"
qiime feature-table summarize \
  --i-table table-dada2.qza \
  --o-visualization table-dada2.qzv \
  --m-sample-metadata-file mapping-file.txt

qiime tools export \
  --input-path table-dada2.qza \
  --output-path exported_table

biom summarize-table \
  -i exported_table/feature-table.biom \
  -o exported_table/feature-table.txt

# generate rep-seqs file
qiime feature-table tabulate-seqs \
  --i-data rep-seqs-dada2.qza \
  --o-visualization rep-seqs-dada2.qzv	

# map rep seqs file to database of choice, right now we are using silva
# this is also computationally so we will use a job for this as well
qiime feature-classifier classify-consensus-vsearch \
  --i-query rep-seqs-dada2.qza \
  --i-reference-reads /$PWD/silva_test/rep_set/silva-138-99-seqs.qza \
  --i-reference-taxonomy /$PWD/silva_test/taxonomy/silva-138-99-tax.qza \
  --o-classification taxonomy.qza

qiime tools export \
  --input-path taxonomy.qza \
  --output-path assigned-taxonomy  

# end of upstream / preprocessing