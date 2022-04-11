#!/bin/bash

# pre-processing human data from tabuladb
bash /usr/local/bin/h5ad_to_matrixmarket_wrapper_tabuladb.sh "tabuladb" "hsap_accession_tabuladb" "hsap_samples_tabuladb"
bash /usr/local/bin/matrixmarket_to_h5ad_wrapper_tabuladb.sh "tabuladb" "hsap_samples_tabuladb"

# pre-processing mouse data from panglaodb
bash /usr/local/bin/rdata_to_matrixmarket_wrapper_panglaodb.sh "panglaodb" "mmus_accession_panglaodb" "mmus_samples_panglaodb"
bash /usr/local/bin/matrixmarket_to_h5ad_wrapper_panglaodb.sh "panglaodb" "mmus_samples_panglaodb"

# generating data used to construct figures and tables
Rscript --vanilla /usr/local/bin/generate_data.R

# generating main figures
Rscript --vanilla /usr/local/bin/generate_main_figures.R

# generating supplementary figures
Rscript --vanilla /usr/local/bin/generate_supplementary_figures.R

# generating supplementary tables
Rscript --vanilla /usr/local/bin/generate_supplementary_tables.R
