#!/bin/bash

csv_to_tsv() {
	cut -d',' -f1-4 | tr -d '"' | tr ',' $'\t'
}

info() { printf "%s\n" "$*" >&2; }

mkdir -p "$PWD/input/panglaodb/panglaodb_ref"

panglaodb_database_url="" # how to programmatically download 31GB tar file if name is scrambled on each download attempt?

panglaodb_cell_type_annotations_url="https://raw.githubusercontent.com/oscar-franzen/PanglaoDB/master/data/cell_type_annotations.txt"

panglaodb_metadata_url="https://raw.githubusercontent.com/oscar-franzen/PanglaoDB/master/data/metadata.txt"
	
info "Downloading and converting PanglaoDB reference data"

if [[ ! -f "$PWD/input/panglaodb/panglaodb_bulk.tar" ]]; then
	curl -L "$panglaodb_database_url" > "$PWD/input/panglaodb/panglaodb_bulk.tar"

if [[ ! -f "$PWD/input/panglaodb/panglaodb_ref/cell_type_annotations.txt" ]]; then
	curl -L "$panglaodb_cell_type_annotations_url" > "$PWD/input/panglaodb/panglaodb_ref/cell_type_annotations.txt"
fi

if [[ ! -f "$PWD/input/panglaodb/panglaodb_ref/metadata.txt" ]]; then
	curl -L "$panglaodb_metadata_url" > "$PWD/input/panglaodb/panglaodb_ref/metadata.txt"
fi

if [[ ! -f "$PWD/input/panglaodb/panglaodb_ref/sample_clusters_cell_types.tsv" ]]; then
	cat "$PWD/input/panglaodb/panglaodb_ref/cell_type_annotations.txt"  | csv_to_tsv | awk -F$'\t' '{ print $1 "_" $2 FS $3 FS $4 }' > $PWD/input/panglaodb/panglaodb_ref/sample_clusters_cell_types.tsv
fi 

if [[ ! -f "$PWD/input/panglaodb/panglaodb_ref/sample_source_meta.tsv" ]]; then
	cat "$PWD/input/panglaodb/panglaodb_ref/metadata.txt"  | csv_to_tsv | awk -F$'\t' '{ gsub(" ","_",$3); print $1 "_" $2 FS $3 FS $5 FS $5 }' > $PWD/input/panglaodb/panglaodb_ref/sample_source_meta.tsv
fi

