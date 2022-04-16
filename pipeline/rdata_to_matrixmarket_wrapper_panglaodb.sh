#!/bin/bash

database_id="$1"
accession_file="$PWD"/input/"$2"
samples_folder="$PWD"/input/"$3"

mkdir -p "$samples_folder"

## storing paths to RData objects for each sample in array (ignoring all but human chromium10x)
RData_array=( $(tar -tf "$PWD"/input/panglaodb_bulk_j2I2pC.tar | grep -f "$accession_file" | grep -v 'RPKM') )

## Shaping data for input to alona pipeline
for RData in "${RData_array[@]}"; do

	sra_srs_file="${RData##*/}"
	sra_srs_folder="${sra_srs_file%%.*}"
	mkdir -p "$samples_folder"/"$sra_srs_folder"

	## extracting RData object from 31 GB tar
	echo "extracting RData"
	tar -xOf "$PWD"/input/panglaodb_bulk_j2I2pC.tar $RData > "$samples_folder"/"$sra_srs_folder"/"$sra_srs_file"

	# echo "constructing MatrixMarket"
	# ./rdata_to_matrixmarket_panglaodb.sh "$samples_folder"/"$sra_srs_folder"/"$sra_srs_file" "$samples_folder"/"$sra_srs_folder"

done
