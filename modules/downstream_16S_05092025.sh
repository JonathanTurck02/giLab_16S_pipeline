#!/bin/bash
#SBATCH --export=NONE
#SBATCH --job-name=ds
#SBATCH --time=0-03:00:00
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=28
#SBATCH --mem=56G
#SBATCH --output=stdout.%x.%j
#SBATCH --error=stderr.%x.%j

# load modules
module load QIIME2/2024.10-Amplicon
export PYTHONNOUSERSITE=1

# ================================================== USER INPUT ================== # Insert mapping file and sampling depth
samplingDepth=XXXX # Set sampling depth for rarefaction -- choose number below lowest feature count in count summary  
mappingFile="metadata.txt" # qiime2 metadata file
columnName='group' # column name in metadata for grouping
z
# STEP1: Filter samples by mapping file
qiime feature-table filter-samples --i-table filtered-feature-table.qza --m-metadata-file ${mappingFile} --o-filtered-table filtered-feature-table.qza

# STEP3: Apply metadata to feature-table
qiime feature-table summarize --i-table filtered-feature-table.qza --m-sample-metadata-file ${mappingFile} --o-visualization filtered-feature-table.qzv

# STEP4: Rarefy feature table
qiime feature-table rarefy --i-table filtered-feature-table.qza --p-sampling-depth ${samplingDepth} --o-rarefied-table rarefied-filtered-feature-table-${samplingDepth}.qza

# STEP5: Generate Taxa Barplot
qiime taxa barplot --i-table rarefied-filtered-feature-table-${samplingDepth}.qza --i-taxonomy taxonomy.qza --m-metadata-file ${mappingFile} --o-visualization taxa-barplot-${samplingDepth}.qzv

# STEP6: Export taxa by level
mkdir -p taxa-by-level

qiime taxa collapse --i-table rarefied-filtered-feature-table-${samplingDepth}.qza --i-taxonomy taxonomy.qza --p-level 2 --o-collapsed-table taxa-by-level/collapsed-filtered-table-L2.qza

qiime tools export --input-path taxa-by-level/collapsed-filtered-table-L2.qza --output-path taxa-by-level/L2-phylum

biom convert -i taxa-by-level/L2-phylum/feature-table.biom -o taxa-by-level/L2-phylum/L2-phylum-table.tsv --to-tsv

qiime taxa collapse --i-table rarefied-filtered-feature-table-${samplingDepth}.qza --i-taxonomy taxonomy.qza --p-level 3 --o-collapsed-table taxa-by-level/collapsed-filtered-table-L3.qza

qiime tools export --input-path taxa-by-level/collapsed-filtered-table-L3.qza --output-path taxa-by-level/L3-class

biom convert -i taxa-by-level/L3-class/feature-table.biom -o taxa-by-level/L3-class/L3-class-table.tsv --to-tsv

qiime taxa collapse --i-table rarefied-filtered-feature-table-${samplingDepth}.qza --i-taxonomy taxonomy.qza --p-level 4 --o-collapsed-table taxa-by-level/collapsed-filtered-table-L4.qza

qiime tools export --input-path taxa-by-level/collapsed-filtered-table-L4.qza --output-path taxa-by-level/L4-order

biom convert -i taxa-by-level/L4-order/feature-table.biom -o taxa-by-level/L4-order/L4-order-table.tsv --to-tsv

qiime taxa collapse --i-table rarefied-filtered-feature-table-${samplingDepth}.qza --i-taxonomy taxonomy.qza --p-level 5 --o-collapsed-table taxa-by-level/collapsed-filtered-table-L5.qza

qiime tools export --input-path taxa-by-level/collapsed-filtered-table-L5.qza --output-path taxa-by-level/L5-family

biom convert -i taxa-by-level/L5-family/feature-table.biom -o taxa-by-level/L5-family/L5-family-table.tsv --to-tsv

qiime taxa collapse --i-table rarefied-filtered-feature-table-${samplingDepth}.qza --i-taxonomy taxonomy.qza --p-level 6 --o-collapsed-table taxa-by-level/collapsed-filtered-table-L6.qza

qiime tools export --input-path taxa-by-level/collapsed-filtered-table-L6.qza --output-path taxa-by-level/L6-genus

biom convert -i taxa-by-level/L6-genus/feature-table.biom -o taxa-by-level/L6-genus/L6-genus-table.tsv --to-tsv

qiime taxa collapse --i-table rarefied-filtered-feature-table-${samplingDepth}.qza --i-taxonomy taxonomy.qza --p-level 7 --o-collapsed-table taxa-by-level/collapsed-filtered-table-L7.qza

qiime tools export --input-path taxa-by-level/collapsed-filtered-table-L7.qza --output-path taxa-by-level/L7-species

biom convert -i taxa-by-level/L7-species/feature-table.biom -o taxa-by-level/L7-species/L7-species-table.tsv --to-tsv

# STEP7: Generate core-metrics, alpha and beta diversity analyses
qiime diversity core-metrics-phylogenetic --i-phylogeny rooted-tree.qza --i-table rarefied-filtered-feature-table-${samplingDepth}.qza --p-sampling-depth ${samplingDepth} --m-metadata-file ${mappingFile} --output-dir core-metrics-outputs

# STEP8: Generate diversity analyses not included in core-metrics
qiime diversity alpha --i-table rarefied-filtered-feature-table-${samplingDepth}.qza --p-metric chao1 --o-alpha-diversity core-metrics-outputs/chao1_vector.qza

qiime diversity alpha --i-table rarefied-filtered-feature-table-${samplingDepth}.qza --p-metric goods_coverage --o-alpha-diversity core-metrics-outputs/goods_coverage_vector.qza

# STEP9: Generate alpha-rarefaction plots
mkdir -p alpha_rarefaction_plots

qiime diversity alpha-rarefaction --i-table filtered-feature-table.qza --i-phylogeny rooted-tree.qza --p-max-depth ${samplingDepth} --p-metrics chao1 --m-metadata-file ${mappingFile} --o-visualization alpha_rarefaction_plots/chao1-plot.qzv

qiime diversity alpha-rarefaction --i-table filtered-feature-table.qza --i-phylogeny rooted-tree.qza --p-max-depth ${samplingDepth} --p-metrics shannon --m-metadata-file ${mappingFile} --o-visualization alpha_rarefaction_plots/shannon-plot.qzv

qiime diversity alpha-rarefaction --i-table filtered-feature-table.qza --i-phylogeny rooted-tree.qza --p-max-depth ${samplingDepth} --p-metrics goods_coverage --m-metadata-file ${mappingFile} --o-visualization alpha_rarefaction_plots/goods_coverage-plot.qzv

# STEP10: Generate alpha diversity boxplots
mkdir -p alpha-diversity

qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-outputs/shannon_vector.qza --m-metadata-file ${mappingFile} --o-visualization alpha-diversity/shannon_boxplot.qzv

qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-outputs/observed_features_vector.qza --m-metadata-file ${mappingFile} --o-visualization alpha-diversity/observed_features_boxplot.qzv

qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-outputs/chao1_vector.qza --m-metadata-file ${mappingFile} --o-visualization alpha-diversity/chao1_boxplot.qzv

qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-outputs/evenness_vector.qza --m-metadata-file ${mappingFile} --o-visualization alpha-diversity/evenness_boxplot.qzv

qiime diversity alpha-group-significance --i-alpha-diversity core-metrics-outputs/goods_coverage_vector.qza --m-metadata-file ${mappingFile} --o-visualization alpha-diversity/goods_coverage_boxplot.qzv

# STEP11: Generate alpha diversity continuous statistics
qiime diversity alpha-correlation --i-alpha-diversity core-metrics-outputs/shannon_vector.qza --m-metadata-file ${mappingFile} --o-visualization alpha-diversity/shannon-alpha-correlation.qzv

qiime diversity alpha-correlation --i-alpha-diversity core-metrics-outputs/observed_features_vector.qza --m-metadata-file ${mappingFile} --o-visualization alpha-diversity/observed_features_correlation.qzv

qiime diversity alpha-correlation --i-alpha-diversity core-metrics-outputs/chao1_vector.qza --m-metadata-file ${mappingFile} --o-visualization alpha-diversity/chao1_correlation.qzv

qiime diversity alpha-correlation --i-alpha-diversity core-metrics-outputs/evenness_vector.qza --m-metadata-file ${mappingFile} --o-visualization alpha-diversity/evenness_correlation.qzv

# STEP12: Perform ANOSIM
mkdir -p beta-diversity

qiime diversity beta-group-significance --i-distance-matrix core-metrics-outputs/bray_curtis_distance_matrix.qza --m-metadata-file ${mappingFile} --m-metadata-column ${columnName} --p-method anosim --p-pairwise --o-visualization beta-diversity/BC-significance-ANOSIM_by_${columnName}.qzv

qiime diversity beta-group-significance --i-distance-matrix core-metrics-outputs/unweighted_unifrac_distance_matrix.qza --m-metadata-file ${mappingFile} --m-metadata-column ${columnName} --p-method anosim --p-pairwise --o-visualization beta-diversity/unweighted_unifrac-significance-ANOSIM_by_${columnName}.qzv

qiime diversity beta-group-significance --i-distance-matrix core-metrics-outputs/weighted_unifrac_distance_matrix.qza --m-metadata-file ${mappingFile} --m-metadata-column ${columnName} --p-method anosim --p-pairwise --o-visualization beta-diversity/weighted_unifrac-significance-ANOSIM_by_${columnName}.qzv

# STEP13: Perform ANCOM
mkdir -p ANCOM-QZA
mkdir -p ANCOM

qiime composition add-pseudocount --i-table taxa-by-level/collapsed-filtered-table-L2.qza --o-composition-table ANCOM-QZA/composition-table-L2.qza
  
qiime composition ancom --i-table ANCOM-QZA/composition-table-L2.qza --m-metadata-file ${mappingFile} --m-metadata-column ${columnName} --o-visualization ANCOM/ancom-${columnName}-L2.qzv

qiime composition add-pseudocount --i-table taxa-by-level/collapsed-filtered-table-L3.qza --o-composition-table ANCOM-QZA/composition-table-L3.qza
  
qiime composition ancom --i-table ANCOM-QZA/composition-table-L3.qza --m-metadata-file ${mappingFile} --m-metadata-column ${columnName} --o-visualization ANCOM/ancom-${columnName}-L3.qzv

qiime composition add-pseudocount --i-table taxa-by-level/collapsed-filtered-table-L4.qza --o-composition-table ANCOM-QZA/composition-table-L4.qza
  
qiime composition ancom --i-table ANCOM-QZA/composition-table-L4.qza --m-metadata-file ${mappingFile} --m-metadata-column ${columnName} --o-visualization ANCOM/ancom-${columnName}-L4.qzv

qiime composition add-pseudocount --i-table taxa-by-level/collapsed-filtered-table-L5.qza --o-composition-table ANCOM-QZA/composition-table-L5.qza
  
qiime composition ancom --i-table ANCOM-QZA/composition-table-L5.qza --m-metadata-file ${mappingFile} --m-metadata-column ${columnName} --o-visualization ANCOM/ancom-${columnName}-L5.qzv

qiime composition add-pseudocount --i-table taxa-by-level/collapsed-filtered-table-L6.qza --o-composition-table ANCOM-QZA/composition-table-L6.qza
  
qiime composition ancom --i-table ANCOM-QZA/composition-table-L6.qza --m-metadata-file ${mappingFile} --m-metadata-column ${columnName} --o-visualization ANCOM/ancom-${columnName}-L6.qzv

qiime composition add-pseudocount --i-table taxa-by-level/collapsed-filtered-table-L7.qza --o-composition-table ANCOM-QZA/composition-table-L7.qza
  
qiime composition ancom --i-table ANCOM-QZA/composition-table-L7.qza --m-metadata-file ${mappingFile} --m-metadata-column ${columnName} --o-visualization ANCOM/ancom-${columnName}-L7.qzv

# STEP14: Perform ANCOMBC
mkdir -p ANCOMBC
mkdir -p ANCOMBC/exports

qiime composition ancombc --i-table taxa-by-level/collapsed-filtered-table-L2.qza --m-metadata-file ${mappingFile} --p-formula ${columnName} --p-p-adj-method hochberg --o-differentials L2_differential_abundance_by_${columnName}.qza

qiime composition tabulate --i-data L2_differential_abundance_by_${columnName}.qza --o-visualization ANCOMBC/L2_differential_abundance_by_${columnName}.qzv

qiime composition da-barplot --i-data L2_differential_abundance_by_${columnName}.qza --o-visualization DA_barplot_L2.qzv

qiime tools export --input-path L2_differential_abundance_by_${columnName}.qza --output-path ANCOMBC/exports/L2-export

qiime composition ancombc --i-table taxa-by-level/collapsed-filtered-table-L3.qza --m-metadata-file ${mappingFile} --p-formula ${columnName} --p-p-adj-method hochberg --o-differentials L3_differential_abundance_by_${columnName}.qza

qiime composition tabulate --i-data L3_differential_abundance_by_${columnName}.qza --o-visualization ANCOMBC/L3_differential_abundance_by_${columnName}.qzv

qiime composition da-barplot --i-data L3_differential_abundance_by_${columnName}.qza --o-visualization DA_barplot_L3.qzv

qiime tools export --input-path L3_differential_abundance_by_${columnName}.qza --output-path ANCOMBC/exports/L3-export

qiime composition ancombc --i-table taxa-by-level/collapsed-filtered-table-L4.qza --m-metadata-file ${mappingFile} --p-formula ${columnName} --p-p-adj-method hochberg --o-differentials L4_differential_abundance_by_${columnName}.qza

qiime composition tabulate --i-data L4_differential_abundance_by_${columnName}.qza --o-visualization ANCOMBC/L4_differential_abundance_by_${columnName}.qzv

qiime composition da-barplot --i-data L4_differential_abundance_by_${columnName}.qza --o-visualization DA_barplot_L4.qzv

qiime tools export --input-path L4_differential_abundance_by_${columnName}.qza --output-path ANCOMBC/exports/L4-export

qiime composition ancombc --i-table taxa-by-level/collapsed-filtered-table-L5.qza --m-metadata-file ${mappingFile} --p-formula ${columnName} --p-p-adj-method hochberg --o-differentials L5_differential_abundance_by_${columnName}.qza

qiime composition tabulate --i-data L5_differential_abundance_by_${columnName}.qza --o-visualization ANCOMBC/L5_differential_abundance_by_${columnName}.qzv

qiime composition da-barplot --i-data L5_differential_abundance_by_${columnName}.qza --o-visualization DA_barplot_L5.qzv

qiime tools export --input-path L5_differential_abundance_by_${columnName}.qza --output-path ANCOMBC/exports/L5-export

qiime composition ancombc --i-table taxa-by-level/collapsed-filtered-table-L6.qza --m-metadata-file ${mappingFile} --p-formula ${columnName} --p-p-adj-method hochberg --o-differentials L6_differential_abundance_by_${columnName}.qza

qiime composition tabulate --i-data L6_differential_abundance_by_${columnName}.qza --o-visualization ANCOMBC/L6_differential_abundance_by_${columnName}.qzv

qiime composition da-barplot --i-data L6_differential_abundance_by_${columnName}.qza --o-visualization DA_barplot_L6.qzv

qiime tools export --input-path L6_differential_abundance_by_${columnName}.qza --output-path ANCOMBC/exports/L6-export

qiime composition ancombc --i-table taxa-by-level/collapsed-filtered-table-L7.qza --m-metadata-file ${mappingFile} --p-formula ${columnName} --p-p-adj-method hochberg --o-differentials L7_differential_abundance_by_${columnName}.qza

qiime composition tabulate --i-data L7_differential_abundance_by_${columnName}.qza --o-visualization ANCOMBC/L7_differential_abundance_by_${columnName}.qzv

qiime composition da-barplot --i-data L7_differential_abundance_by_${columnName}.qza --o-visualization DA_barplot_L7.qzv

qiime tools export --input-path L7_differential_abundance_by_${columnName}.qza --output-path ANCOMBC/exports/L7-export

echo Downstream complete proceed to taxa summary