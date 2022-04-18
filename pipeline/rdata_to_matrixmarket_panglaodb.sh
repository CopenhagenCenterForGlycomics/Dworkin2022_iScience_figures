#!/bin/bash

data_file="$1"

outputdir="${2:-output}"

info() { printf "%s\n" "$*" >&2; }
	
rdata_parent=$(dirname "$data_file")
rdata_filename=$(basename "$data_file")

sample_identifier=${rdata_filename/.sparse.RData/}

output_matrixmarket="${outputdir}/${sample_identifier}.tar.gz"

info "Extracting data from RData file"
	
# Dump Matrix objects from within R
r_command="load('${rdata_parent}/${rdata_filename}'); Matrix::writeMM(sm, '${rdata_parent}/matrix.mtx'); writeLines(sm@Dimnames[[1]], '${rdata_parent}/genes.tsv'); writeLines(sm@Dimnames[[2]], '${rdata_parent}/barcodes.tsv')"
	
R -e "$r_command"
	
tar -zcvf "$output_matrixmarket" -C "${outputdir}" matrix.mtx genes.tsv barcodes.tsv && rm "${outputdir}/matrix.mtx" "${outputdir}/genes.tsv" "${outputdir}/barcodes.tsv"
	
info "Created MatrixMarket targz file $output_matrixmarket"
	
info "Retrieving the pre-annotated clusters for $output_matrixmarket"

panglaodb_seurat_base_url="https://raw.githubusercontent.com/oscar-franzen/PanglaoDB/master/data/sample_clusters"

curl -L "${panglaodb_seurat_base_url}/${sample_identifier}.seurat_clusters.txt" > "${rdata_parent}/${sample_identifier}".seurat_clusters.txt

cluster_cell_types="$PWD/input/panglaodb/panglaodb_ref/sample_clusters_cell_types.tsv"
seurat_clusters="${rdata_parent}/${sample_identifier}.seurat_clusters.txt"

join -t$'\t' -1 2 -2 2 <(grep -F "$sample_identifier" "$cluster_cell_types" | sort -t$'\t' -n -k2 ) <(cat "$seurat_clusters" | tr ' ' $'\t' | sort -t$'\t' -n -k2 ) | awk -F$'\t' '{ print $4 FS $3 FS $1}' > "${outputdir}/${sample_identifier}.cell_annotation.tsv" && rm $seurat_clusters
