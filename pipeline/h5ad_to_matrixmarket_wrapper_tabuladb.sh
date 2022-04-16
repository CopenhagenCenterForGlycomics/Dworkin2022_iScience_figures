#!/bin/bash

database_id="$1"
accession_file="$PWD"/input/"$2"
samples_folder="$PWD"/input/"$3"

mkdir -p "$samples_folder"
	
## storing paths to H5ad objects for each sample in array (each sample contains both chromium10x and smartseq2 reads)
H5ad_array=( $(tar -tf "$PWD"/input/TabulaSapiensV3.tgz | grep -f "$accession_file" | grep -v './._') )

## Shaping data for input to alona pipeline
for H5ad in "${H5ad_array[@]}"; do
	
	tissue_file="$H5ad"
	echo "tissue file is $tissue_file"
	tissue_folder="${H5ad%%.*}"
	echo "tissue folder is $tissue_folder"
	mkdir -p "$samples_folder"/"$tissue_folder"
	
	if ! [ -f "$samples_folder"/"$tissue_folder"/"$tissue_folder".cell_annotation.tsv ]; then
		
		## extracting H5ad object from 15 GB tar
		echo "extracting H5ad"
		tar -xOzf "$PWD"/input/TabulaSapiensV3.tgz $H5ad > "$samples_folder"/"$tissue_folder"/"$tissue_file"
		
		## echo "constructing MatrixMarket"
		#./h5ad_to_matrixmarket_tabuladb.sh "$database_id" "$samples_folder"/"$tissue_folder"/"$tissue_file" "$samples_folder"/"$tissue_folder"
		
	fi

done
		
