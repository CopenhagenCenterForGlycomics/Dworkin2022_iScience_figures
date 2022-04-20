setwd('/home/preprocess/generate_model_data')
here::i_am('generate_model_data.R')

writeLines('preparing model data')
rmarkdown::render("generate_model_data.Rmd")
remove(list = ls())

