#!/bin/bash

echo "Starting execution for processing pipeline"

database="$1"

inputfile="$2"

filename=$(basename $2)

tissue=${3:-"no-tissue"}

outdir=${4:-"output"}

mkdir -p "$outdir"

if [ "$database" == "panglaodb" ]; then

	annotations="${inputfile/.tar.gz/.cell_annotation.tsv}"

	outfile="$outdir/${filename/.tar.gz/.h5ad}"

	outfile_pseudobulk="$outdir/${filename/.tar.gz/_pseudobulk.h5ad}"

	outfile_pseudobulk_rds="${outfile_pseudobulk/.h5ad/.Rds}"

	python3 /usr/local/bin/matrixmarket_to_processed_h5ad_scanpy_panglaodb.py "$database" "$inputfile" "$outfile" "$annotations" "$tissue"

elif [ "$database" == "tabuladb" ]; then

	annotations="${inputfile/.h5ad.zip/.cell_annotation.tsv}"

	outfile="$outdir/${filename/.h5ad.zip/.h5ad}"

	outfile_pseudobulk="$outdir/${filename/.h5ad.zip/_pseudobulk.h5ad}"

	outfile_pseudobulk_rds="${outfile_pseudobulk/.h5ad/.Rds}"

	python3 /usr/local/bin/matrixmarket_to_processed_h5ad_scanpy_tabula_sapiens.py "$database" "$inputfile" "$outfile" "$annotations" "$tissue"

fi

Rscript --vanilla /usr/local/bin/h5ad_to_rds.R "$outfile_pseudobulk" "$outfile_pseudobulk_rds"
