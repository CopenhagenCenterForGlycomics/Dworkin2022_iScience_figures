#!/bin/bash

info() { printf "%s\n" "$*" >&2; }

mkdir -p "$PWD/input/tabuladb/tabuladb_ref"

tabuladb_database_url="https://figshare.com/ndownloader/files/28846647"

info "Downloading and converting PanglaoDB reference data"

# Did I download each file individually, or all together?
if [[ ! -f "$PWD/input/tabuladb/TabulaSapiensV3.tgz" ]]; then
	curl -L "$tabuladb_database_url" > "$PWD/input/tabuladb/TabulaSapiensV3.h5ad.zip"
	# extract accession list here
	# extract barcodes here
	# tar h5ad.zip files here
fi

