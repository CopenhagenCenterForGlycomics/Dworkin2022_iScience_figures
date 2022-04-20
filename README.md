# Workflow

## Building of the pipeline
```
DOCKER_IMAGE="figure_generation_pipeline:latest"
docker build . -t "$DOCKER_IMAGE"
```

## Running the pipeline
```
docker run --rm -it -v "$PWD/mount":/home "DOCKER_IMAGE"
```

## Output:

### Bulk data generation:
```
/preprocess/generate_bulk_data/
  |_0.generate_bulk_data
  |_1.generate_bulk_heatmaps
```

### Single Cell data generation:
```
/preprocess/generate_single_cell_data/
  |_0.generate_pseudobulk_human
  |_0.generate_pseudobulk_mouse
  |_0.generate_pseudopresence_human
  |_1.generate_pseudobulkpresence
  |_2.generate_clrs
  |_2.generate_log_seg_norm
```

### Main Figure generation:
```
/result/
  |_Figure2
  |_Figure3
  |_Figure4
  |_Figure5
```

### Supplementary Figure generation:
```
/result/
  |_SupplementaryFigure2
  |_SupplementaryFigure3
  |_SupplementaryFigure4
  |_SupplementaryFigure5
  |_SupplementaryFigure6
```

### Supplementary Table generation:
```
/result/
  |_SupplementaryTable1
  |_SupplementaryTable2
  |_SupplementaryTable3
```
