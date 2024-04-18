
# import sequences
qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path manifest.txt \
  --input-format PairedEndFastqManifestPhred33V2 \
  --output-path ../demux-paired-end.qza

# make visualization
qiime demux summarize \
  --i-data demux-paired-end.qza \
  --o-visualization demux-paired-end.qzv