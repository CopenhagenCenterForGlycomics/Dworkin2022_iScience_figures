#!/bin/bash

# pre-processing human data from tabuladb
# bash /usr/local/bin/preprocess_pipeline_wrapper_tabuladb.sh "tabuladb" "hsap_accession_tabuladb.txt" "hsap_samples_tabuladb"
cp /results/input/hsap_samples_tabuladb/*/*.Rds.gz /results/generate_single_cell_data/hsap_tabuladb_pseudobulk/
cp /results/input/hsap_samples_tabuladb/*/*pseudopresence.tsv.gz /results/generate_single_cell_data/hsap_tabuladb_pseudopresence/

# pre-processing mouse data from panglaodb
# bash /usr/local/bin/preprocess_pipeline_wrapper_panglaodb.sh "panglaodb" "mmus_accession_panglaodb.txt" "mmus_samples_panglaodb"
cp /results/input/mmus_samples_tabuladb/*/*.Rds.gz /results/generate_single_cell_data/mmus_panglaodb_pseudobulk/
cp /results/input/mmus_samples_tabuladb/*/*pseudopresence.tsv.gz /results/generate_single_cell_data/mmus_tabuladb_pseudopresence/

# generating data used to construct figures and tables
Rscript --vanilla /usr/local/bin/generate_data.R

# generating main figures
Rscript --vanilla /usr/local/bin/generate_main_figures.R

# generating supplementary figures
Rscript --vanilla /usr/local/bin/generate_supplementary_figures.R

# generating supplementary tables
Rscript --vanilla /usr/local/bin/generate_supplementary_tables.R
