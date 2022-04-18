#!/bin/bash

info() { printf "%s\n" "$*" >&2; }

scp_database_url="https://singlecell.broadinstitute.org/single_cell/data/public/SCP426/single-cell-comparison-mixture-data"

mkdir -p "$PWD/input/scp"

info "Downloading broad institute reference data"

if [[ ! -f "$PWD/input/scp/human_mixture1_genes_results.txt.gz" ]]; then
	download_url="${scp_database_url}?filename=human_mixture1_genes_results.txt"
	curl -L "$download_url" > "$PWD/input/scp/human_mixture1_genes_results.txt"
	gzip -f "$PWD/input/scp/human_mixture1_genes_results.txt"
fi

if [[ ! -f "$PWD/input/scp/human_mixture2_genes_results.txt.gz" ]]; then
	download_url="${scp_database_url}?filename=human_mixture2_genes_results.txt"
	curl -L "$download_url" > "$PWD/input/scp/human_mixture2_genes_results.txt"
	gzip -f "$PWD/input/scp/human_mixture2_genes_results.txt"
fi

if [[ ! -f "$PWD/input/scp/cellnames.umis.txt.gz" ]]; then
	download_url="${scp_database_url}?filename=cellnames.umis.txt"
	curl -L "$download_url" > "$PWD/input/scp/cellnames.umis.txt"
	gzip -f "$PWD/input/scp/cellnames.umis.txt"
fi

if [[ ! -f "$PWD/input/scp/genes.txt.gz" ]]; then
	download_url="${scp_database_url}?filename=genes.txt"
	curl -L "$download_url" > "$PWD/input/scp/genes.txt"
	gzip -f "$PWD/input/scp/genes.txt"
fi

if [[ ! -f "$PWD/input/scp/umis.counts.txt.gz" ]]; then
	download_url="${scp_database_url}?filename= umis.counts.txt"
	curl -L "$download_url" > "$PWD/input/scp/umis.counts.txt"
	gzip -f "$PWD/input/scp/umis.counts.txt"
fi
