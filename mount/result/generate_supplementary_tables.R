here::i_am('generate_supplementary_tables.R')
library(here)
require(rmarkdown)

writeLines('generating SupplementaryTable1')
setwd(here('result/SupplementaryTable1'))
rmarkdown::render("SupplementaryTable1.Rmd")
remove(list = ls())

writeLines('generating SupplementaryTable2')
setwd(here('result/SupplementaryTable2'))
rmarkdown::render("SupplementaryTable2.Rmd")
remove(list = ls())

writeLines('generating SupplementaryTable3')
setwd(here('result/SupplementaryTable3'))
rmarkdown::render("SupplementaryTable3.Rmd")
remove(list = ls())

