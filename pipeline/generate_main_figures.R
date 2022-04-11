here::i_am('generate_main_figures.R')
library(here)
require(rmarkdown)

writeLines('generating bulk heatmaps')
setwd(here('generate_bulk_data'))
rmarkdown::render("1.generate_bulk_heatmaps.Rmd")
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
