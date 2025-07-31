#!/bin/bash
#SBATCH --export=NONE
#SBATCH --job-name=import
#SBATCH --time=0-02:00:00
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=38
#SBATCH --mem=250G
#SBATCH --output=stdout.%x.%j
#SBATCH --error=stderr.%x.%j


# load modules
module load QIIME2/2024.10-Amplicon
export PYTHONNOUSERSITE=1

# ================================================== USER INPUT ================== 
netID="your_netID" # replace with your netID
# remember to copy script_bank into your scratch directory
# trimming in this script defaults to the usual MRDNA primer set

# STEP1: Create Manifest File
cp /scratch/user/${netID}/script_bank/create-manifest-final.sh ./demux

cd demux

bash create-manifest-final.sh

mv manifest.txt ..
cd ..

echo manifest.txt created successfully

# STEP2: Import sequences into qiime2
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path manifest.txt --input-format PairedEndFastqManifestPhred33V2 --output-path ./demux-paired-end.qza

# STEP3: Visualize quality
mkdir -p qc

qiime demux summarize --i-data demux-paired-end.qza --o-visualization qc/pretrim-demux-paired-end.qzv

# STEP4: cutadapt to remove primers
qiime cutadapt trim-paired --i-demultiplexed-sequences demux-paired-end.qza --p-cores 8 --p-front-f 'GTGYCAGCMGCCGCGGTAA' --p-front-r 'GGACTACNVGGGTWTCTAAT' --o-trimmed-sequences trimmed-demux.qza 

# STEP5: Visualize quality after adaptor trimming
qiime demux summarize --i-data trimmed-demux.qza --o-visualization qc/trimmed-demux.qzv

echo Data imported and quality plots prepared, review quality visualizations before proceeding