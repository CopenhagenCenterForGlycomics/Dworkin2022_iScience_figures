here::i_am('master.R')
library(here)
require(rmarkdown)

writeLines('generating bulk data')
setwd(here('generate_bulk_data'))
rmarkdown::render("0.generate_bulk_data.Rmd")
remove(list = ls())

writeLines('generating bulk heatmaps')
setwd(here('generate_bulk_data'))
rmarkdown::render("1.generate_bulk_heatmaps.Rmd")
remove(list = ls())

writeLines('generating single cell pseudobulks for human')
setwd(here('generate_single_cell_data'))
rmarkdown::render("0.generate_pseudobulk_human.Rmd")
remove(list = ls())

writeLines('generating single cell pseudobulks for mouse')
setwd(here('generate_single_cell_data'))
rmarkdown::render("0.generate_pseudobulk_mouse.Rmd")
remove(list = ls())

writeLines('generating single cell pseudopresence for human')
setwd(here('generate_single_cell_data'))
rmarkdown::render("0.generate_pseudopres_human.Rmd")
remove(list = ls())

writeLines('combining single cell pseudobulks and pseudopresence')
setwd(here('generate_single_cell_data'))
rmarkdown::render("1.generate_pseudobulkpresence.Rmd")
remove(list = ls())

writeLines('generating single cell clr pseudobulks')
setwd(here('generate_single_cell_data'))
rmarkdown::render("2.generate_clrs.Rmd")
remove(list = ls())

writeLines('generating single cell log seg pseudobulks')
setwd(here('generate_single_cell_data'))
rmarkdown::render("2.generate_log_seg_norm.Rmd")
remove(list = ls())

writeLines('generating single cell heatmaps')
setwd(here('generate_single_cell_data'))
rmarkdown::render("3.generate_singlecell_heatmaps.Rmd")
remove(list = ls())

writeLines('generating Figure2B')
setwd(here('Figure2'))
rmarkdown::render("Figure2B.Rmd")
remove(list = ls())
 
writeLines('generating Figure3B')
setwd(here('Figure3'))
rmarkdown::render("Figure3B.Rmd")
remove(list = ls())
 
writeLines('generating Figure4CDE')
setwd(here('Figure4'))
rmarkdown::render("Figure4CDE.Rmd")
remove(list = ls())
 
writeLines('generating Figure5A')
setwd(here('Figure5'))
rmarkdown::render("Figure5A.Rmd")
remove(list = ls())

writeLines('generating SupplementaryFigure3A')
setwd(here('SupplementaryFigure3'))
rmarkdown::render("SupplementaryFigure3A.Rmd")
remove(list = ls())

writeLines('generating SupplementaryFigure3BCD')
setwd(here('SupplementaryFigure3'))
rmarkdown::render("SupplementaryFigure3BCD.Rmd")
remove(list = ls())

writeLines('generating SupplementaryFigure4')
setwd(here('SupplementaryFigure4'))
rmarkdown::render("SupplementaryFigure4.Rmd")
remove(list = ls())

writeLines('generating SupplementaryFigure5A')
setwd(here('SupplementaryFigure5'))
rmarkdown::render("SupplementaryFigure5A.Rmd")
remove(list = ls())

writeLines('generating SupplementaryFigure5B')
setwd(here('SupplementaryFigure5'))
rmarkdown::render("SupplementaryFigure5B.Rmd")
remove(list = ls())

writeLines('generating SupplementaryFigure6')
setwd(here('SupplementaryFigure6'))
rmarkdown::render("SupplementaryFigure6.Rmd")
remove(list = ls())

writeLines('generating SupplementaryTable1')
setwd(here('SupplementaryTable1'))
rmarkdown::render("SupplementaryTable1.Rmd")
remove(list = ls())

writeLines('generating SupplementaryTable2')
setwd(here('SupplementaryTable2'))
rmarkdown::render("SupplementaryTable2.Rmd")
remove(list = ls())

writeLines('generating SupplementaryTable3')
setwd(here('SupplementaryTable3'))
rmarkdown::render("SupplementaryTable3.Rmd")
remove(list = ls())

