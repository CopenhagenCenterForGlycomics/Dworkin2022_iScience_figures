#!/bin/bash

info() { printf "%s\n" "$*" >&2; }

mkdir -p "$PWD/input/tcga/"

tcga_database_url="http://duffel.rail.bio/recount/v2/TCGA/rse_gene.Rdata"

info "Downloading TCGA reference data"

if [[ ! -f "$PWD/input/tcga/rse_gene_tcga.Rdata" ]]; then
	curl -L "$tcga_database_url" > "$PWD/input/tcga/rse_gene_tcga.Rdata"
fi

