AUTHOR: Jonathan Turck
UPDATE_DATE: 5.23.2024

# Title: GI Lab 16S Analysis Pipeline

# Description: 
    ```This pipeline entails a 16S amplicon qiime2 workflow that works from raw reads and generates alpha diversity, beta diversity, and differential abundance statistics. 

    The pipeline depends on three batch scripts that handle general checkpoints in the pipeline. At each step some user quality control checks are implemented and case specific inputs are required.

    This script is currently in its BETA version. Please contact jonathanturck@tamu.edu if you find any issues or are confused with any documentation. You can also report and problems directly to the issues tab in github

    For GI Lab Users:
    navigate to the folder "Jonathan Turck/16S_pipeline_2024" to download the most recent files to run this pipeline.```
# Table of Contents
1: Installation
    1.1: Setting Up Your Environment

# Installation
## Setting Up Your Environment
    ```While these scripts can work with an linux system that has qiime2 installed its main intention is to be used in tandem with HPC clusters like TAMU HPRC GRACE.```

    ```_For GRACE users_
    Begin by logging into your scratch directory and uploading the three core scripts:
    - INDEV_preprocess.sh
    - INDEV_upstream.sh
    - INDEV_downstream.sh```

    ```Then upload the script-bank directly to your scratch directory
        The script-bank is a folder that includes the SILVA database for taxonomic assignment and the create-manifest.sh script that is needed to import the sequences into qiime2.```
# Features

# Usage/Implementation