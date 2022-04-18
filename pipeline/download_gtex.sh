#!/bin/bash

info() { printf "%s\n" "$*" >&2; }

mkdir -p "$PWD/input/gtex/"

gtex_database_url="http://duffel.rail.bio/recount/v2/SRP012682/rse_gene.Rdata"

info "Downloading GTEX reference data"

if [[ ! -f "$PWD/input/gtex/rse_gene_gtex.Rdata" ]]; then
	curl -L "$gtex_database_url" > "$PWD/input/gtex/rse_gene_gtex.Rdata"
fi

