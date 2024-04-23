# before downstream ensure that the dysbiosis index results are included in the mapping file
    # will do correlations on alpha, beta, and taxa metrics

# This command list handles the less computationally intensive part of analysis
# The goal is to create metrics that reflect the assigned taxonomy, alpha, and beta diversity
# A variety of matrices should be included for clients

# additional filtering step if you just want to look at a subset of samples
qiime feature-table filter-samples \
  --i-table filtered-table-dada2.qza \
  --m-metadata-file $mappingFile \
  --o-filtered-table filtered-table-dada2.qza

# summarize the filtered-table-dada2.qza from the upstream
qiime feature-table summarize \
  --i-table filtered-table-dada2.qza \
  --m-sample-metadata-file $mappingFile \
  --o-visualization filtered-table-dada2.qzv

# export the raw data of the filtered exported table and covert to tsv
qiime tools export \
  --input-path filtered-table-dada2.qza \
  --output-path filtered_exported_table

biom summarize-table \
  -i filtered_exported_table/feature-table.biom \
  -o filtered_exported_table/feature-table.tsv

# this is where we typically performed rarefaction in the past

#Alpha and Beta Diversity core-metrics (there is also a nonphylo version for this that can be used for shotgun)
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny rooted-tree.qza \
  --i-table filtered-table-dada2.qza \
  --p-sampling-depth $samplingDepth \
  --m-metadata-file $mappingFile \
  --output-dir core-metrics-outputs

# alpha diversity metrics not included in core metrics, this needs to have the samples rarefied
qiime feature-table rarefy \
  --i-table filtered-table-dada2.qza \
  --p-sampling-depth $samplingDepth \
  --o-rarefied-table rarefied-filtered-table-dada2-$samplingDepth.qza

mkdir core-metrics-outputs/alpha-div

qiime diversity alpha \
  --i-table rarefied-filtered-table-dada2-$samplingDepth.qza \
  --p-metric chao1 \
  --o-alpha-diversity chao1_vector.qza

qiime diversity alpha \
  --i-table rarefied-filtered-table-dada2-$samplingDepth.qza \
  --p-metric goods_coverage \
  --o-alpha-diversity goods_coverage_vector.qza

# export the raw core-metrics dm as tsvs
mkdir core-metrics-outputs/raw-distance-matrices

qiime tools export \
  --input-path core-metrics-outputs/evenness_vector.qza \
  --output-path core-metrics-outputs/raw-distance-matrices/alpha-div/eveness

qiime tools export \
  --input-path core-metrics-outputs/faith_pd_vector.qza \
  --output-path core-metrics-outputs/raw-distance-matrices/alpha-div/faith_pd

qiime tools export \
  --input-path core-metrics-outputs/observed_features_vector.qza \
  --output-path core-metrics-outputs/raw-distance-matrices/alpha-div/observed_features_vector

qiime tools export \
  --input-path core-metrics-outputs/shannon_vector.qza \
  --output-path core-metrics-outputs/raw-distance-matrices/alpha-div/shannon

qiime tools export \
  --input-path core-metrics-outputs/bray_curtis_distance_matrix.qza \
  --output-path core-metrics-outputs/raw-distance-matrices/beta-div/bray_curtis_dm

qiime tools export \
  --input-path core-metrics-outputs/unweighted_unifrac_distance_matrix.qza \
  --output-path core-metrics-outputs/raw-distance-matrices/beta-div/unweighted_unifrac_dm

qiime tools export \
  --input-path core-metrics-outputs/weighted_unifrac_distance_matrix.qza \
  --output-path core-metrics-outputs/raw-distance-matrices/beta-div/weighted_unifrac_dm


# make rarefaction plots
mkdir alpha_rarefaction_plots

qiime diversity alpha-rarefaction \
  --i-table filtered-table-dada2.qza \
  --i-phylogeny rooted-tree.qza \
  --p-max-depth $samplingDepth \
  --p-metrics chao1 \
  --m-metadata-file $mappingFile \
  --o-visualization alpha_rarefaction_plots/chao1-plot.qzv
# this is just chao1 for right now, I can also add the other alpha diversity matrices


# taxa collapse, generate taxa-barplot and then collapse to levels to process relative abundances
#Barplot of Taxonomies
qiime taxa barplot \
  --i-table filtered-table-dada2.qza \
  --i-taxonomy taxonomy.qza \
  --m-metadata-file $mappingFile \
  --o-visualization taxa-barplot-filtered-table-dada2.qzv
# test a barplot with rarefaction to see how it changes


# collapse for every availible level
# Level 2, phylum
qiime taxa collapse \
  --i-table filtered-table-dada2.qza \
  --i-taxonomy taxonomy.qza \
  --p-level 2 \
  --o-collapsed-table collapsed-taxa-qza/collapsed-filtered-table-L2.qza

qiime tools export \
  --input-path collapsed-taxa-qza/collapsed-filtered-table-L2.qza \
  --output-path collapsed-taxa-qza/L2-feature-table

biom convert \
 -i collapsed-taxa-qza/L2-feature-table/feature-table.biom \
 -o collapsed-taxa-qza/L2-feature-table/L2-phylum-table.tsv --to-tsv

# Level 3, class
qiime taxa collapse \
  --i-table filtered-table-dada2.qza \
  --i-taxonomy taxonomy.qza \
  --p-level 3 \
  --o-collapsed-table collapsed-taxa-qza/collapsed-filtered-table-L3.qza

qiime tools export \
  --input-path collapsed-taxa-qza/collapsed-filtered-table-L3.qza \
  --output-path collapsed-taxa-qza/L3-feature-table

biom convert \
 -i collapsed-taxa-qza/L3-feature-table/feature-table.biom \
 -o collapsed-taxa-qza/L3-feature-table/L3-class-table.tsv --to-tsv

# Level 4, order
qiime taxa collapse \
  --i-table filtered-table-dada2.qza \
  --i-taxonomy taxonomy.qza \
  --p-level 4 \
  --o-collapsed-table collapsed-taxa-qza/collapsed-filtered-table-L4.qza

qiime tools export \
  --input-path collapsed-taxa-qza/collapsed-filtered-table-L4.qza \
  --output-path collapsed-taxa-qza/L4-feature-table

biom convert \
 -i collapsed-taxa-qza/L4-feature-table/feature-table.biom \
 -o collapsed-taxa-qza/L4-feature-table/L4-class-table.tsv --to-tsv

# Level 5, family
qiime taxa collapse \
  --i-table filtered-table-dada2.qza \
  --i-taxonomy taxonomy.qza \
  --p-level 5 \
  --o-collapsed-table collapsed-taxa-qza/collapsed-filtered-table-L5.qza

qiime tools export \
  --input-path collapsed-taxa-qza/collapsed-filtered-table-L5.qza \
  --output-path collapsed-taxa-qza/L5-feature-table

biom convert \
 -i collapsed-taxa-qza/L5-feature-table/feature-table.biom \
 -o collapsed-taxa-qza/L5-feature-table/L5-family-table.tsv --to-tsv

# Level 6, genus
qiime taxa collapse \
  --i-table filtered-table-dada2.qza \
  --i-taxonomy taxonomy.qza \
  --p-level 6 \
  --o-collapsed-table collapsed-taxa-qza/collapsed-filtered-table-L6.qza

qiime tools export \
  --input-path collapsed-taxa-qza/collapsed-filtered-table-L6.qza \
  --output-path collapsed-taxa-qza/L6-feature-table

biom convert \
 -i collapsed-taxa-qza/L6-feature-table/feature-table.biom \
 -o collapsed-taxa-qza/L6-feature-table/L6-genus-table.tsv --to-tsv

# Level 7, species
qiime taxa collapse \
  --i-table filtered-table-dada2.qza \
  --i-taxonomy taxonomy.qza \
  --p-level 7 \
  --o-collapsed-table collapsed-taxa-qza/collapsed-filtered-table-L7.qza

qiime tools export \
  --input-path collapsed-taxa-qza/collapsed-filtered-table-L7.qza \
  --output-path collapsed-taxa-qza/L7-feature-table

biom convert \
 -i collapsed-taxa-qza/L7-feature-table/feature-table.biom \
 -o collapsed-taxa-qza/L7-feature-table/L7-species-table.tsv --to-tsv


# diversity analyses statistics

# alpha statistics
mkdir alpha-diversity

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-outputs/shannon_vector.qza \
  --m-metadata-file $mappingFile \
  --o-visualization shannon_significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-outputs/observed_features_vector.qza \
  --m-metadata-file $mappingFile \
  --o-visualization observed_features_significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-outputs/chao1_vector.qza \
  --m-metadata-file $mappingFile \
  --o-visualization chao1_significance.qzv

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-outputs/evenness_vector.qza \
  --m-metadata-file $mappingFile \
  --o-visualization evenness_significance.qzv 

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-outputs/goods_coverage_vector.qza \
  --m-metadata-file $mappingFile \
  --o-visualization alpha-diversity/goods_coverage_significance.qzv

### alpha diversity continuous statistics
qiime diversity alpha-correlation \
    --i-alpha-diversity core-metrics-outputs/shannon_vector.qza \
    --m-metadata-file $mappingFile \
    --o-visualization shannon-alpha-correlation.qzv

qiime diversity alpha-correlation \
  --i-alpha-diversity core-metrics-outputs/observed_features_vector.qza \
  --m-metadata-file $mappingFile \
  --o-visualization observed_features_correlation.qzv

qiime diversity alpha-correlation \
  --i-alpha-diversity core-metrics-outputs/alpha-div/chao1_vector.qza \
  --m-metadata-file $mappingFile \
  --o-visualization chao1_vector.qzv

qiime diversity alpha-correlation \
  --i-alpha-diversity core-metrics-outputs/evenness_vector.qza \
  --m-metadata-file $mappingFile \
  --o-visualization evenness_vector.qzv

# beta statistics -- via ANOSIM
mkdir beta-diversity

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-outputs/bray_curtis_distance_matrix.qza \
  --m-metadata-file $mappingFile \
  --m-metadata-column $columnName \
  --p-method anosim \
  --p-pairwise \
  --o-visualization beta-diversity/BC-significance-ANOSIM.qzv 

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-outputs/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file $mappingFile \
  --m-metadata-column $columnName \
  --p-method anosim \
  --p-pairwise \
  --o-visualization beta-diversity/unweighted_unifrac-significance-ANOSIM.qzv 

qiime diversity beta-group-significance \
  --i-distance-matrix core-metrics-outputs/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file $mappingFile \
  --m-metadata-column $columnName \
  --p-method anosim \
  --p-pairwise \
  --o-visualization beta-diversity/weighted_unifrac-significance-ANOSIM.qzv 

### beta diversity continuous statistics
#### using default parameters, including 999 permutations and spearman rank
qiime diversity beta-correlation \
  --i-distance-matrix core-metrics-outputs/bray_curtis_distance_matrix.qza \
  --m-metadata-file $mappingFile \
  --m-metadata-column $columnName \
  --o-metadata-distance-matrix beta-diversity/bray_curtis_metadata_distance_matrix.qza \
  --o-mantel-scatter-visualization beta-diversity/bray_curtis_mantel_scatter.qzv

qiime diversity beta-correlation \
  --i-distance-matrix core-metrics-outputs/unweighted_unifrac_distance_matrix.qza \
  --m-metadata-file $mappingFile \
  --m-metadata-column $columnName \
  --o-metadata-distance-matrix beta-diversity/unweighted_unifrac_metadata_distance_matrix.qza \
  --o-mantel-scatter-visualization beta-diversity/unweighted_unifrac_mantel_scatter.qzv

qiime diversity beta-correlation \
  --i-distance-matrix core-metrics-outputs/weighted_unifrac_distance_matrix.qza \
  --m-metadata-file $mappingFile \
  --m-metadata-column $columnName \
  --o-metadata-distance-matrix beta-diversity/weighted_unifrac_metadata_distance_matrix.qza \
  --o-mantel-scatter-visualization beta-diversity/weighted_unifrac_mantel_scatter.qzv

# differential abundance with ANOCOMBC
qiime composition ancombc \
 --i-table filtered-table-dada2.qza \
 --m-metadata-file $mappingFile \
 --p-formula '$columnName' \
 --p-p-adj-method hochberg \
 --o-differentials differential_abundance_by_$columnName.qza

qiime composition tabulate \
  --i-data differential_abundance_by_$columnName.qza \
  --o-visualization differential_abundance_by_$columnName.qzv

qiime composition da-barplot \
  --i-data differential_abundance_by_$columnName.qza \
  --o-visualization DA_barplot.qzv

# heatmap visualization
qiime feature-table heatmap \
 --i-table filtered-table-dada2.qza \
 --m-sample-metadata-file $mappingFile \
 --m-sample-metadata-column $columnName \
 --o-visualization filtered-table-dada2-heatmap.qzv
 
