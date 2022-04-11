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

panglaodb_cell_type_annotations_url="https://raw.githubusercontent.com/oscar-franzen/PanglaoDB/master/data/cell_type_annotations.txt"

panglaodb_metadata_url="https://raw.githubusercontent.com/oscar-franzen/PanglaoDB/master/data/metadata.txt"

panglaodb_seurat_base_url="https://raw.githubusercontent.com/oscar-franzen/PanglaoDB/master/data/sample_clusters"
	
mkdir -p "$PWD/panglaodb_ref"

info "Downloading and converting PanglaoDB reference data"

if [[ ! -f "$PWD/panglaodb_ref/cell_type_annotations.txt" ]]; then
	curl -L "$panglaodb_cell_type_annotations_url" > "$PWD/panglaodb_ref/cell_type_annotations.txt"
fi

if [[ ! -f "$PWD/panglaodb_ref/metadata.txt" ]]; then
	curl -L "$panglaodb_metadata_url" > "$PWD/panglaodb_ref/metadata.txt"
fi

if [[ ! -f "$PWD/panglaodb_ref/sample_clusters_cell_types.tsv" ]]; then
	cat "$PWD/panglaodb_ref/cell_type_annotations.txt"  | csv_to_tsv | awk -F$'\t' '{ print $1 "_" $2 FS $3 FS $4 }' > $PWD/panglaodb_ref/sample_clusters_cell_types.tsv
fi 

if [[ ! -f "$PWD/panglaodb_ref/sample_source_meta.tsv" ]]; then
	cat "$PWD/panglaodb_ref/metadata.txt"  | csv_to_tsv | awk -F$'\t' '{ gsub(" ","_",$3); print $1 "_" $2 FS $3 FS $5 FS $5 }' > $PWD/panglaodb_ref/sample_source_meta.tsv
fi

rdata_parent=$(dirname "$data_file")
rdata_filename=$(basename "$data_file")

sample_identifier=${rdata_filename/.sparse.RData/}

output_matrixmarket="${outputdir}/${sample_identifier}.tar.gz"

if [[ ! -f "$output_matrixmarket" ]]; then
	
	info "Extracting data from RData file"
	
	# Dump Matrix objects from within R
	r_command="load('${rdata_parent}/${rdata_filename}'); Matrix::writeMM(sm, '$PWD/matrix.mtx'); writeLines(sm@Dimnames[[1]], '$PWD/genes.tsv'); writeLines(sm@Dimnames[[2]], '$PWD/barcodes.tsv')"
	
	data_path="$rdata_parent" r_docker R -e "$r_command"
	
	tar -zcvf "$output_matrixmarket" matrix.mtx genes.tsv barcodes.tsv && rm matrix.mtx genes.tsv barcodes.tsv
	
	info "Created MatrixMarket targz file $output_matrixmarket"
	
fi

info "Retrieving the pre-annotated clusters for $output_matrixmarket"

curl -L "${panglaodb_seurat_base_url}/${sample_identifier}.seurat_clusters.txt" > "${sample_identifier}.seurat_clusters.txt"

cluster_cell_types="$PWD/panglaodb_ref/sample_clusters_cell_types.tsv"
seurat_clusters="${sample_identifier}.seurat_clusters.txt"

join -t$'\t' -1 2 -2 2 <(grep -F "$sample_identifier" "$cluster_cell_types" | sort -t$'\t' -n -k2 ) <(cat "$seurat_clusters" | tr ' ' $'\t' | sort -t$'\t' -n -k2 ) | awk -F$'\t' '{ print $4 FS $3 FS $1}' > "${outputdir}/${sample_identifier}.cell_annotation.tsv" && rm $seurat_clusters