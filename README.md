# Workflow

## Building of the pipeline
```
R_IMAGE="panglao_pipeline:latest"
docker build . -t "$R_IMAGE"
```

## Running the pipeline
```
# Fires up a docker container in the background, only needs base R
R_IMAGE="$R_IMAGE" rdata_to_matrixmarket.sh Whatever.Rdata

# Output: Whatever.tar.gz

# From within a docker container set up for the pipeline
docker run --rm -it -v "$PWD":"$PWD" -w "$PWD" "$R_IMAGE" Whatever.tar.gz outdir

# Output:
outdir/Whatever.h5ad
outdir/Whatever_pseudobulk.h5ad
outdir/Whatever_pseudobulk.rds
outdir/Whatever_pseudobulk.tsv
```

# Bulk data generation:
```
0.generate_bulk_data
  |_0.generate_bulk_data
  |_1.generate_bulk_heatmaps
```

# Single Cell data generation:
```
1.generate_single_cell_data
  |_0.generate_pseudobulk_human
  |_0.generate_pseudobulk_mouse
  |_0.generate_pseudopresence_human
  |_1.generate_pseudobulkpresence
  |_2.generate_clrs
  |_2.generate_log_seg_norm
  |_3.generate_single_cell_heatmaps.Rmd
```

# Main Figure generation:
```
2.Figure2
3.Figure3
4.Figure4
5.Figure5
```

# Supplementary Figure generation:
```
6.SupplementaryFigure3
7.SupplementaryFigure4
8.SupplementaryFigure5
9.SupplementaryFigure6
```

# Table generation:
```
10.SupplementaryTable1
11.SupplementaryTable2 # <-- double check cell types for mouse
12.SupplementaryTable3
```
