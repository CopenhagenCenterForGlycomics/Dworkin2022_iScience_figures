here::i_am('generate_data.R')
library(here)
require(rmarkdown)

writeLines('generating bulk data')
setwd(here('generate_bulk_data'))
rmarkdown::render("0.generate_bulk_data.Rmd")
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
