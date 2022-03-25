
suggested pipeline for generating data and figures:

0.generate_bulk_data
  |_0.generate_bulk_data
  |_1.generate_bulk_heatmaps

1.generate_single_cell_data
  |_0.generate_pseudobulk_human
  |_0.generate_pseudobulk_mouse
  |_0.generate_pseudopresence_human
  |_1.generate_pseudobulkpresence
  |_2.generate_clrs
  |_2.generate_log_seg_norm
  |_3.generate_single_cell_heatmaps.Rmd

2.Figure2
3.Figure3
4.Figure4
5.Figure5

6.SupplementaryFigure3
7.SupplementaryFigure4
8.SupplementaryFigure5
9.SupplementaryFigure6

10.SupplementaryTable1
11.SupplementaryTable2 # <-- double check cell types for mouse
12.SupplementaryTable3
