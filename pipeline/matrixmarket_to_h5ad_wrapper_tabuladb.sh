#!/bin/bash

database_id="$1"
samples_folder="$2"
base="$PWD"

for tissue_folder in "$samples_folder"/TS*/; do
	
	tissue_id=$(basename "$tissue_folder")
	echo "$tissue_id"
	
	tissue="${tissue_id:3}"
	
	cd "$tissue_folder"
	
	if ! [ -f *pseudobulk.h5ad ]; then
		
		bash /usr/local/bin/perform_preprocessing_pipeline.sh "$database_id" "$tissue_id".h5ad.zip "$tissue" .
		# docker run --rm -it -v "$PWD":"$PWD" -w "$PWD" "$R_IMAGE" "$database_id" "$tissue_id".h5ad.zip "$tissue" .
		
		rm "$tissue_id".h5ad
		rm "$tissue_id".cell_annotation.tsv
		
	fi
	
	cd "$base"
	
done
