setwd('/home/result/')
here::i_am('generate_supplementary_figures.R')
library(here)
require(rmarkdown)

writeLines('generating SupplementaryFigure2A')
setwd(here('SupplementaryFigure2'))
rmarkdown::render("SupplementaryFigure2A.Rmd")
remove(list = ls())

writeLines('generating SupplementaryFigure2B')
setwd(here('SupplementaryFigure2'))
rmarkdown::render("SupplementaryFigure2B.Rmd")
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
