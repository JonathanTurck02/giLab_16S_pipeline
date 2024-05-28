# GI Lab 16S Analysis Pipeline

**Author:** Jonathan Turck  
**Last Updated:** 5.28.2024

## Description

This pipeline entails a 16S amplicon qiime2 workflow that works from raw reads and generates alpha diversity, beta diversity, and differential abundance statistics.

The pipeline depends on three batch scripts that handle general checkpoints in the pipeline. At each step, some user quality control checks are implemented and case-specific inputs are required.

This script is currently in its BETA version. Please contact [jonathanturck@tamu.edu](mailto:jonathanturck@tamu.edu) if you find any issues or are confused with any documentation. You can also report any problems directly to the issues tab on GitHub.

**For GI Lab Users:**  
Navigate to the folder `Jonathan Turck/16S_pipeline_2024` to download the most recent files to run this pipeline.

## Table of Contents

1. [Installation](#installation)
    1. [Setting Up Your Environment](#setting-up-your-environment)
2. [Features](#features)
3. [Usage/Implementation](#usageimplementation)

## Installation

### Setting Up Your Environment

While these scripts can work with a Linux system that has qiime2 installed, their main intention is to be used in tandem with HPC clusters like TAMU HPRC GRACE.

**For GRACE users:**  
Begin by logging into your scratch directory and uploading the three core scripts:
- `INDEV_preprocess.sh`
- `INDEV_upstream.sh`
- `INDEV_downstream.sh`

Then upload the script-bank directly to your scratch directory.  
The script-bank is a folder that includes the SILVA database for taxonomic assignment and the `create-manifest.sh` script that is needed to import the sequences into qiime2.

## Features
- Utilizes qiime2 to perform quality control, mapping to phylogeny, and downstream analyses. 
**Pre-processing**
This porion of the pipeline imports that raw fastq (sequences + quality information) into qiime2 via creation of a manifest file. It then trims the Illumina primers using cutadpat and creates visualizations to view the overall quality of the sequences. After the running this script the user should review the quality plots to adjust trimming parameters for the upstream.

### Upstream
This portion of the pipeline handles quality trimming and the computationally heavy processes. First, user specified truncation lengths are set for the forward and reverse reads. This script also takes a mapping file as input which will be used to assign metadata at some steps of the upstream.
The DADA2 algorithm is used to identify the amplicon sequence variants and trim low quality regions. These features are then mapped against the SILVA 16S database for classification using the consensus-vsearch algorithm. Finally the features and taxonomy are assembled in the a phylogenic tree for use in some downstream analyses.

### Downstream
This portion of the pipeline handles creation of alpha diversity, beta diversity, and differential abundance statistics. A rarefaction depth is specified by the user to allow even sampling across all samples during alpha and beta diveristy analyses. A column of interest from the metadata file is also specified which will be used as the catergorical variable in downstream statistics. 
For differential abundance analysis Analysis of Compositions of Microbiomes (ANOM) and Analysis of Compositions of Microbiomes with Bias Correction (ANCOM-BC) are performed. These differential abudance methods take into account the compositionality of microbiome data.

## Usage/Implementation

**Dependencies**
- script_bank folder
    - can be found in the GitHub or on the GI lab shared drive at 'Jonathan Turck/16S_pipeline_2024'

**Trimming**
A general rule of thumb for picking the truncation lengths for the trimming step is to find where the score begins to dip below 30. Pick a position around this point to be truncation length.

For example if the forward read is 200bp long and it begins to lose quality below 30 at 150bp then specify 'trunclenF=150'.

**Execution Order**
(Bullet points specify if any user inputs are needed)
1. preprocess.sh
    - Specify 'netID' in user variable
    - _This script assumes that the raw files are located in a demux folder_
2. upsteam.sh
    - Forward truncation length 'trunclenF'
    - Reverse truncation length 'trunclenR'
    - user 'netID'
    - mapping file with metadata 'mappingFile' (file name with extension; must be present in project folder)
3. downstream.sh
    - Rarefaction depth 'samplingDepth'
        - _Rule of Thumb:_ minimum reads from count_summary directory minus 5
    - mapping file with metadata 'mappingFile' (file name with extension; must be present in project folder)
    - column of interest: exact match of column name to run statistics on in the mapping file; 'columnName'


