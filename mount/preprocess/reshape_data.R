here::i_am('reshape_data.R')
library(here)
require(rmarkdown)

writeLines('preparing bulk data')
setwd(here('/preprocess/generate_bulk_data'))
rmarkdown::render("0.generate_bulk_data.Rmd")
remove(list = ls())

writeLines('preparing single cell pseudobulks for human')
setwd(here('/preprocess/generate_single_cell_data'))
rmarkdown::render("0.generate_pseudobulk_human.Rmd")
remove(list = ls())

writeLines('preparing single cell pseudobulks for mouse')
setwd(here('/preprocess/generate_single_cell_data'))
rmarkdown::render("0.generate_pseudobulk_mouse.Rmd")
remove(list = ls())

writeLines('preparing single cell pseudopresence for human')
setwd(here('/preprocess/generate_single_cell_data'))
rmarkdown::render("0.generate_pseudopres_human.Rmd")
remove(list = ls())

writeLines('combining single cell pseudobulks and pseudopresence')
setwd(here('/preprocess/generate_single_cell_data'))
rmarkdown::render("1.generate_pseudobulkpresence.Rmd")
remove(list = ls())

writeLines('preparing single cell clr pseudobulks')
setwd(here('/preprocess/generate_single_cell_data'))
rmarkdown::render("2.generate_clrs.Rmd")
remove(list = ls())

writeLines('preparing single cell log seg pseudobulks')
setwd(here('/preprocess/generate_single_cell_data'))
rmarkdown::render("2.generate_log_seg_norm.Rmd")
remove(list = ls())
