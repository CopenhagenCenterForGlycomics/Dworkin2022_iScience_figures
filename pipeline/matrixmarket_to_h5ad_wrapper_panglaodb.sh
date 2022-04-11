#!/bin/bash

database_id="$1"
samples_folder="$2"
base="$PWD"

for sra_srs_folder in "$samples_folder"/SRA*/; do
	
	sra_srs_id=$(basename "$sra_srs_folder")
	echo "$sra_srs_id"
	
	tissue=$(grep "$sra_srs_id" panglaodb_ref/sample_source_meta.tsv | cut -f2 | sed 's/[^A-Za-z0-9.-]/_/g')
	
	cd "$sra_srs_folder"
	
	if ! [ -f *pseudobulk.h5ad ]; then
		
		bash /usr/local/bin/perform_preprocessing_pipeline.sh "$database_id" "$sra_srs_id".tar.gz "$tissue" .
		
		rm "$sra_srs_id".tar.gz
		rm "$sra_srs_id".sparse.RData
		rm "$sra_srs_id".cell_annotation.tsv
		
	fi
	
	cd "$base"
	
done
