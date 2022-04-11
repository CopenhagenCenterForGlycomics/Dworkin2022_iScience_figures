#!/bin/bash

R_IMAGE=${R_IMAGE:-"panglao_pipeline:latest"}

database_id="$1"

data_file="$2"

outputdir="${3:-output}"

csv_to_tsv() {
	cut -d',' -f1-4 | tr -d '"' | tr ',' $'\t'
}

r_docker() {
	data_path="${data_path:-$PWD}"
	volume_args=""
	if [[ $data_path = /* ]]; then
		volume_args="-v $data_path:$data_path"
	fi
	docker run --entrypoint "" --rm -v "$PWD":"$PWD" -w "$PWD" $volume_args "$R_IMAGE" "$@"
}

info() { printf "%s\n" "$*" >&2; }


h5ad_parent=$(dirname "$data_file")
h5ad_filename=$(basename "$data_file")

sample_identifier=${h5ad_filename/.h5ad.zip/}
				
info "Extracting data from H5ad file"
	
# Dump barcodes from within R
r_command="unzip('${h5ad_parent}/${h5ad_filename}', exdir='${h5ad_parent}'); file <- gsub('\\\.zip', '', '${h5ad_filename}'); file.h5ad <- hdf5r::H5File\$new(filename = file.path('${h5ad_parent}', file), mode = 'r'); writeLines(file.h5ad[['obs/cell_id']][], '${h5ad_parent}/barcodes.tsv'); file.h5ad\$close();"

data_path="$h5ad_parent" r_docker R -e "$r_command"

rm "$h5ad_parent"/*.h5ad

info "dumped $sample_identifier barcodes"

info "Retrieving the pre-annotated clusters for $output_matrixmarket"

cluster_cell_types="$PWD/tabula_ref/sample_clusters_cell_types.tsv"

join -t$'\t' -1 4 -2 1 <(grep -F "$sample_identifier" tabula_ref/sample_clusters_cell_types.tsv | sort -t$'\t' -k4) <(sort -t$'\t' -k1 "$h5ad_parent"/barcodes.tsv) > "${outputdir}/${sample_identifier}.cell_annotation.tsv" && rm "$h5ad_parent"/barcodes.tsv
