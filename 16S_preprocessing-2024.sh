# This command list handles the initial importing and preprocessing of the data
# A manifest file must be created to handle this
# $case-sensitive input/output, please specify specific file name, path, or depth

# create manifest w/ create-manifest.sh

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path $manifest \
  --input-format PairedEndFastqManifestPhred33V2 \
  --output-path demux-paired-end.qza

