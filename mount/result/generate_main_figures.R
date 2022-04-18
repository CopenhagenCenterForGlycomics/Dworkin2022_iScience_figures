here::i_am('generate_main_figures.R')
library(here)
require(rmarkdown)

writeLines('generating Figure2B')
setwd(here('result/Figure2'))
rmarkdown::render("Figure2B.Rmd")
remove(list = ls())
 
writeLines('generating Figure3B')
setwd(here('result/Figure3'))
rmarkdown::render("Figure3B.Rmd")
remove(list = ls())
 
writeLines('generating Figure4CDE')
setwd(here('result/Figure4'))
rmarkdown::render("Figure4CDE.Rmd")
remove(list = ls())
 
writeLines('generating Figure5A')
setwd(here('result/Figure5'))
rmarkdown::render("Figure5A.Rmd")
remove(list = ls())
