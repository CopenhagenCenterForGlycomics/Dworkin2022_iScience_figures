library(hdf5r)
library(Matrix)

args = commandArgs(trailingOnly=TRUE)

file.h5 <- H5File$new(args[1], mode="r+")
tissue_type = file.h5[['uns/tissue']][]
genes = file.h5[['obsm/hgnc']][]
ensembl = file.h5[['obsm/gene']][]
clusternumber = file.h5[['varm/cluster_number']][]
celltype = file.h5[['varm/celltype']][]
clustersize = file.h5[['varm/cluster_size']][]
sparse = as(file.h5[['X']][,],"sparseMatrix")
dimnames(sparse) = list(paste(celltype,clusternumber,sep='_cluster_'),genes)
attributes(sparse)$celltype = celltype
attributes(sparse)$clusternumber = clusternumber
attributes(sparse)$clustersize = clustersize
attributes(sparse)$ensembl = ensembl
attributes(sparse)$tissue = tissue_type
saveRDS(sparse,args[2])

