#!/bin/bash

database_id="$1"
accession_file="$PWD"/input/"$2"
samples_folder="$PWD"/input/"$3"

mkdir -p "$samples_folder"

## storing paths to RData objects for each sample in array (ignoring all but human chromium10x)
RData_array=( $(tar -tf "$PWD"/input/panglaodb_bulk_j2I2pC.tar | grep -f "$accession_file" | grep -v 'RPKM') )
RData_array=("${RData_array[0]}")

for RData in "${RData_array[@]}"; do

	sra_srs_file="${RData##*/}"
	echo "sra_srs file is $sra_srs_file"

	sra_srs_folder="${sra_srs_file%%.*}"
	echo "sra_sra folder is $sra_srs_folder"

	tissue=$(grep "$sra_srs_folder" "$PWD"/input/panglaodb_ref/sample_source_meta.tsv | cut -f2 | sed 's/[^A-Za-z0-9.-]/_/g')
	echo "tissue is $tissue"

	mkdir -p "$samples_folder"/"$sra_srs_folder"

	## extracting RData object from 31 GB tar
	echo "extracting RData"
	tar -xOf "$PWD"/input/panglaodb_bulk_j2I2pC.tar $RData > "$samples_folder"/"$sra_srs_folder"/"$sra_srs_file"

	## building MatrixMarket from RData object
	# echo "constructing MatrixMarket"
	bash /usr/local/bin/rdata_to_matrixmarket_panglaodb.sh "$samples_folder"/"$sra_srs_folder"/"$sra_srs_file" "$samples_folder"/"$sra_srs_folder"

	## preprocessing MatrixMarket object
	echo "preprocessing MatrixMarket object"
	bash /usr/local/bin/preprocess_pipeline.sh "$database_id" "$samples_folder"/"$sra_srs_folder"/"${sra_srs_file/.sparse.RData/.tar.gz}" "$tissue" "$samples_folder"/"$sra_srs_folder"

	## compressing each output file	
	gzip -f "$samples_folder"/"$sra_srs_folder"/"${sra_srs_file/.sparse.RData/_pseudobulk.Rds}"
	gzip -f "$samples_folder"/"$sra_srs_folder"/"${sra_srs_file/.sparse.RData/_pseudobulk.tsv}"
	gzip -f "$samples_folder"/"$sra_srs_folder"/"${sra_srs_file/.sparse.RData/_pseudopresence.tsv}"
	gzip -f "$samples_folder"/"$sra_srs_folder"/"${sra_srs_file/.sparse.RData/_pseudobulk.h5ad}"
	gzip -f "$samples_folder"/"$sra_srs_folder"/"${sra_srs_file/.sparse.RData/.h5ad}"

	## renaming each output file
	mv "$samples_folder"/"$sra_srs_folder"/"${sra_srs_file/.sparse.RData/_pseudobulk.Rds.gz}" \
	"$samples_folder"/"$sra_srs_folder"/panglao_10090_"$tissue"_chromium10x_"${sra_srs_file/.sparse.RData/_pseudobulk.Rds.gz}"
	mv "$samples_folder"/"$sra_srs_folder"/"${sra_srs_file/.sparse.RData/_pseudobulk.tsv.gz}" \
	"$samples_folder"/"$sra_srs_folder"/panglao_10090_"$tissue"_chromium10x_"${sra_srs_file/.sparse.RData/_pseudobulk.tsv.gz}"
	mv "$samples_folder"/"$sra_srs_folder"/"${sra_srs_file/.sparse.RData/_pseudopresence.tsv.gz}" \
	"$samples_folder"/"$sra_srs_folder"/panglao_10090_"$tissue"_chromium10x_"${sra_srs_file/.sparse.RData/_pseudopresence.tsv.gz}"
	mv "$samples_folder"/"$sra_srs_folder"/"${sra_srs_file/.sparse.RData/_pseudobulk.h5ad.gz}" \
	"$samples_folder"/"$sra_srs_folder"/panglao_10090_"$tissue"_chromium10x_"${sra_srs_file/.sparse.RData/_pseudobulk.h5ad.gz}"
	mv "$samples_folder"/"$sra_srs_folder"/"${sra_srs_file/.sparse.RData/.h5ad.gz}" \
	"$samples_folder"/"$sra_srs_folder"/panglao_10090_"$tissue"_chromium10x_"${sra_srs_file/.sparse.RData/.h5ad.gz}"

	## removing extraneous files
	rm "$samples_folder"/"$sra_srs_folder"/"${sra_srs_file/.sparse.RData/.tar.gz}"
	rm "$samples_folder"/"$sra_srs_folder"/"${sra_srs_file/.sparse.RData/.cell_annotation.tsv}"
	rm "$samples_folder"/"$sra_srs_folder"/"$sra_srs_file"

done
