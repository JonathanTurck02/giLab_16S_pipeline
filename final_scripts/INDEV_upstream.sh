#!/bin/bash
#SBATCH --export=NONE
#SBATCH --job-name=job-name
#SBATCH --time=2-00:00:00
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=28
#SBATCH --mem=56G
#SBATCH --output=stdout.%x.%j
#SBATCH --error=stderr.%x.%j

# load modules
module load Anaconda3/2023.07-2
source activate /sw/hprc/sw/Anaconda3/2023.07-2/envs/qiime2-2024.2-amplicon

# ================================================== USER INPUT ================== # Truncate around where q-score drops below 30 (f-233 r-231)
trunclenF=XXX 
trunclenR=XXX  
user=netID
mappingFile="mapping_file.txt"
# remember to copy script_bank into your scratch directory

# STEP1: DADA2 ASV identification and trimming
qiime dada2 denoise-paired --i-demultiplexed-seqs trimmed-demux.qza --p-trunc-len-f ${trunclenF} --p-trunc-len-r ${trunclenR} --o-representative-sequences asv-seqs.qza --o-table feature-table.qza --o-denoising-stats denoising-stats.qza

# STEP2: Review DADA2 run statistics
qiime metadata tabulate --m-input-file denoising-stats.qza --o-visualization qc/denoising-stats-summ.qzv

# STEP3: Review feature-table and export summ stats to txt
qiime feature-table summarize --i-table feature-table.qza --m-sample-metadata-file ${mappingFile} --o-visualization feature-table-summ.qzv

qiime tools export --input-path feature-table.qza --output-path counts_summary

biom summarize-table -i counts_summary/feature-table.biom -o counts_summary/feature-table-summ.txt

# STEP4: Review ASVs
qiime feature-table tabulate-seqs --i-data asv-seqs.qza --o-visualization asv-seqs-summ.qzv

# STEP5: Classify features with SILVA
qiime feature-classifier classify-consensus-vsearch --i-query asv-seqs.qza --i-reference-reads /scratch/user/${user}/script_bank/silva/rep_set/silva-138-99-seqs.qza --i-reference-taxonomy /scratch/user/${user}/script_bank/silva/taxonomy/silva-138-99-tax.qza --o-classification taxonomy.qza --o-search-results blast_results.qza

# STEP6: Export taxonomy
qiime tools export --input-path taxonomy.qza --output-path taxonomy

qiime metadata tabulate --m-input-file taxonomy.qza --o-visualization taxonomy/taxonomy.qzv

# STEP7: Filter out chloroplast and mitochondria
qiime taxa filter-table --i-table feature-table.qza --i-taxonomy taxonomy.qza --p-mode contains --p-include p__ --p-exclude 'p__;,Chloroplast,Mitochondria' --o-filtered-table filtered-feature-table.qza

# STEP8: Filter ASVs
qiime feature-table filter-seqs --i-data asv-seqs.qza --i-table filtered-feature-table.qza --o-filtered-data filtered-asv-seqs.qza

# STEP9: Assign phylongeny
qiime phylogeny align-to-tree-mafft-fasttree --i-sequences filtered-asv-seqs.qza --o-alignment aligned-asv-seqs.qza --o-masked-alignment masked-aligned-asv-seqs.qza --o-tree unrooted-tree.qza --o-rooted-tree rooted-tree.qza

echo Upstream completed review denoising stats and feature table summary before proceeding