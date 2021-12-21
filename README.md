
suggested pipeline for generating data and figures:

0.generate_bulk_data
  |_0.generate_bulk_data <-- processing of GTEx and SC
  |_1.generate_bulk_heatmaps <-- (placeholder currently. Where is code for generating heat map raw values?)
  
1.generate_single_cell_data
  |_0.generate_pseudobulk_human
  |_0.generate_pseudobulk_mouse
  |_0.generate_pseudopresence_human (considering moving to Table3)
  |_1.generate_clrs
  |_1.generate_log_seg_norm
  |_2.generate_single_cell_heatmaps.Rmd (code for generating heat map raw values is here)
  
2.Figure2 <-- Figure2Aplaceholder.Rmd (code for bulk rainbow figure generation; necessary?)
3.Figure3 <-- Figure3Aplaceholder.Rmd (code for single cell rainbow figure generation; necessary?)
4.Figure4 <-- Figure4ABplaceholder.Rmd (code for single cell ubiquitous, cell specific, and isoform expression; necessary?)
5.Figure5
6.Table1 <-- placeholder.Rmd (Leo needs to find code; easy)
7.Table2 <-- placeholder.Rmd (Leo needs to find code; easy)
8.Table3 
9.SupplementaryFigure1 <-- placeholder.Rmd (code for blank rainbow figure generation; necessary?)
10.SupplementaryFigure2 <-- placeholder.Rmd (code for bulk and single cell rainbow figure generation; necessary?)
11.SupplementaryFigure3 
12.SupplementaryFigure4 <-- placeholder.Rmd (Leo needs to dig back through repo; not terrible)
13.SupplementaryFigure5
14.SupplementaryFigure6

Questions: where should excel sheets and Rds generated in generate_bulk_data and generate_single_cell_data go?
Questions: where should manually curated datasets used in downstream analyses go? IE, glycoenzymes.xlsx, glycogenes.tsv, etc, epitopes.xlsx
