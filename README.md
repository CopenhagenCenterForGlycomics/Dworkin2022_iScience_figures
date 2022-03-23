
suggested pipeline for generating data and figures:

0.generate_bulk_data
  |_0.generate_bulk_data ✅
  |_1.generate_bulk_heatmaps <-- (placeholder currently. Where is code for generating heat map raw values for bulk data?)

1.generate_single_cell_data
  |_0.generate_pseudobulk_human ✅
  |_0.generate_pseudobulk_mouse ✅
  |_0.generate_pseudopresence_human ✅
  |_1.generate_pseudobulkpresence ✅
  |_2.generate_clrs ✅
  |_2.generate_log_seg_norm ✅
  |_3.generate_single_cell_heatmaps.Rmd ✅

2.Figure2 ✅<-- Figure2Aplaceholder.Rmd (code for bulk rainbow figure generation; necessary?)
3.Figure3 ✅<-- Figure3Aplaceholder.Rmd (code for single cell rainbow figure generation; necessary?)
4.Figure4 ✅<-- Figure4ABplaceholder.Rmd (code for single cell ubiquitous, cell specific, and isoform expression; necessary?)
5.Figure5 ✅
6.SupplementaryTable1 ✅
7.SupplementaryTable2 ✅
8.SupplementaryTable3 ✅
9.SupplementaryFigure1 <-- placeholder.Rmd (code for blank rainbow figure generation; necessary?)
10.SupplementaryFigure2 <-- placeholder.Rmd (code for bulk and single cell rainbow figure generation; necessary?)
11.SupplementaryFigure3 ✅
12.SupplementaryFigure4 ✅
13.SupplementaryFigure5 ✅
14.SupplementaryFigure6 ✅
