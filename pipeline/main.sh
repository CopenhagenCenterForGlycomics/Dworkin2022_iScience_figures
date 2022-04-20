#!/bin/bash

## downloading ##
# downloading scp input data
# bash /usr/local/bin/download_scp.sh

# downloading panglaodb input data
# bash /usr/local/bin/download_panglaodb.sh

# downloading tabuladb input data
# bash /usr/local/bin/download_tabuladb.sh

# downloading gtex input data
bash /usr/local/bin/download_gtex.sh

# downloading tcga input data
bash /usr/local/bin/download_tcga.sh

## preprocessing ##
# pre-processing human data from tabuladb
bash /usr/local/bin/preprocess_pipeline_wrapper_tabuladb.sh "tabuladb" "hsap_accession_tabuladb.txt" "hsap_samples_tabuladb"

# pre-processing mouse data from panglaodb
bash /usr/local/bin/preprocess_pipeline_wrapper_panglaodb.sh "panglaodb" "mmus_accession_panglaodb.txt" "mmus_samples_panglaodb"

# pre-processing model data from scp
bash /usr/local/bin/preprocess_pipeline_wrapper_scp.sh

# reshaping processed human, mouse, and model data
bash /usr/local/bin/reshape_data.sh

## results ##
# generating main figures
bash /usr/local/bin/generate_main_figures.sh

# generating supplementary figures
bash /usr/local/bin/generate_supplementary_figures.sh

# generating supplementary tables
bash /usr/local/bin/generate_supplementary_tables.sh
