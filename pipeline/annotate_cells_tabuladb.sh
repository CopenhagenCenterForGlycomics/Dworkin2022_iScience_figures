#!/bin/bash

data_file="$1"

outputdir="${2:-output}"

info() { printf "%s\n" "$*" >&2; }

h5ad_parent=$(dirname "$data_file")
h5ad_filename=$(basename "$data_file")

sample_identifier=${h5ad_filename/.h5ad.zip/}
				
info "Extracting data from H5ad file"
	
# Dump barcodes from within R
r_command="unzip('${h5ad_parent}/${h5ad_filename}', exdir='${h5ad_parent}'); file <- gsub('\\\.zip', '', '${h5ad_filename}'); file.h5ad <- hdf5r::H5File\$new(filename = file.path('${h5ad_parent}', file), mode = 'r'); writeLines(file.h5ad[['obs/cell_id']][], '${h5ad_parent}/barcodes.tsv'); file.h5ad\$close();"
R -e "$r_command"

rm "$h5ad_parent"/*.h5ad

info "dumped $sample_identifier barcodes"

info "Retrieving the pre-annotated clusters for $sample_identifier"

cluster_cell_types="$PWD/input/tabuladb/tabuladb_ref/sample_clusters_cell_types.tsv"

join -t$'\t' -1 4 -2 1 <(grep -F "$sample_identifier" "$cluster_cell_types" | sort -t$'\t' -k4) <(sort -t$'\t' -k1 "$h5ad_parent"/barcodes.tsv) > "${outputdir}/${sample_identifier}.cell_annotation.tsv" && rm "$h5ad_parent"/barcodes.tsv
