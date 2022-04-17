#!/bin/bash

database_id="$1"
accession_file="$PWD"/input/"$2"
samples_folder="$PWD"/input/"$3"

mkdir -p "$samples_folder"
	
## storing paths to H5ad objects for each sample in array (each sample contains both chromium10x and smartseq2 reads)
H5ad_array=( $(tar -tf "$PWD"/input/TabulaSapiensV3.tgz | grep -f "$accession_file" | grep -v './._') )
H5ad_array=("${H5ad_array[0]}")

## Shaping data for input to alona pipeline
for H5ad in "${H5ad_array[@]}"; do
	
	tissue_file="$H5ad"
	echo "tissue file is $tissue_file"

	tissue_folder="${H5ad%%.*}"
	echo "tissue folder is $tissue_folder"

	tissue="${tissue_folder:3}"
	echo "tissue is $tissue"

	mkdir -p "$samples_folder"/"$tissue_folder"
			
	## extracting H5ad object from 15 GB tar
	echo "extracting H5ad"
	tar -xOzf "$PWD"/input/TabulaSapiensV3.tgz $H5ad > "$samples_folder"/"$tissue_folder"/"$tissue_file"
		
	## extracting cell type annotation from H5ad object
	echo "extracting cell type annotations"
	bash /usr/local/bin/annotate_cells_tabuladb.sh "$samples_folder"/"$tissue_folder"/"$tissue_file" "$samples_folder"/"$tissue_folder"

	## preprocessing H5ad object
	echo "preprocessing H5ad object"
	bash /usr/local/bin/preprocess_pipeline.sh "$database_id" "$samples_folder"/"$tissue_folder"/"$tissue_file" "$tissue" "$samples_folder"/"$tissue_folder"

	# compressing each output file	
	gzip -f "$samples_folder"/"$tissue_folder"/"${tissue_file/.h5ad.zip/_pseudobulk.Rds}"
	gzip -f "$samples_folder"/"$tissue_folder"/"${tissue_file/.h5ad.zip/_pseudobulk.tsv}"
	gzip -f "$samples_folder"/"$tissue_folder"/"${tissue_file/.h5ad.zip/_pseudopresence.tsv}"
	gzip -f "$samples_folder"/"$tissue_folder"/"${tissue_file/.h5ad.zip/_pseudobulk.h5ad}"
	gzip -f "$samples_folder"/"$tissue_folder"/"${tissue_file/.h5ad.zip/.h5ad}"

	# removing extraneous files
	rm "$samples_folder"/"$tissue_folder"/"${tissue_file/.h5ad.zip/.cell_annotation.tsv}"
	rm "$samples_folder"/"$tissue_folder"/"$tissue_file"

done
		
