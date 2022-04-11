import sys
import os
import tarfile
import zipfile
import tempfile
import shutil

import numpy as np
import pandas as pd
import scanpy as sc
import csv
import anndata

from scipy.stats import norm
from sklearn.mixture import GaussianMixture


def calculate_qc(adata):
  
    if 'mito' not in adata.var.columns:
        adata.var['mito'] = adata.var_names.str.startswith('MT-')
        
    if 'ribo' not in adata.var.columns:
        adata.var['ribo'] = adata.var_names.str.startswith('RPL') | adata.var_names.str.startswith('RPS')
        
    if 'hb' not in adata.var.columns:
        adata.var['hb'] = adata.var_names.str.startswith('HB')
        
    qc_tbls = sc.pp.calculate_qc_metrics(adata, qc_vars = ['mito', 'ribo', 'hb'], percent_top = [50])
    
    adata.obs['n_counts'] = qc_tbls[0]['total_counts'].values
    adata.obs['log1p_n_counts'] = np.log1p(adata.obs['n_counts'])
    adata.obs['n_genes'] = qc_tbls[0]['n_genes_by_counts'].values
    adata.obs['log1p_n_genes'] = np.log1p(adata.obs['n_genes'])
    adata.obs['percent_mito'] = qc_tbls[0]['pct_counts_mito'].values
    adata.obs['percent_ribo'] = qc_tbls[0]['pct_counts_ribo'].values
    adata.obs['percent_hb'] = qc_tbls[0]['pct_counts_hb'].values
    adata.obs['percent_top50'] = qc_tbls[0]['pct_counts_in_top_50_genes'].values
    adata.var['n_counts'] = qc_tbls[1]['total_counts'].values
    adata.var['n_cells'] = qc_tbls[1]['n_cells_by_counts'].values

def _scale_factor(x):
  
    xmin = np.min(x)
    xmax = np.max(x)
    
    return 5.0 / (xmax - xmin)

def fit_gaussian(x, n=10, threshold=0.05, xmin=None, xmax=None, nbins=500, hist_bins=100):
  
    xmin = x.min() if xmin is None else xmin
    xmax = x.max() if xmax is None else xmax
    
    gmm = GaussianMixture(n_components=n, random_state=0)
    x_fit = x[(x>=xmin) & (x<=xmax)]
    f = _scale_factor(x_fit)
    x_fit = x_fit * f
    gmm.fit(x_fit.reshape(-1, 1))
    
    while not gmm.converged_:
        gmm.fit(x_fit.reshape(-1, 1), warm_start=True)
        
    x0 = np.linspace(x.min(), x.max(), num=nbins)
    y_pdf = np.zeros((n, nbins))
    y_cdf = np.zeros((n, nbins))
    
    for i in range(n):
        y_pdf[i] = norm.pdf(x0 * f, loc=gmm.means_[i, 0], scale=n  *gmm.covariances_[i, 0, 0]) * gmm.weights_[i]
        y_cdf[i] = norm.cdf(x0 * f, loc=gmm.means_[i, 0], scale=n  *gmm.covariances_[i, 0, 0]) * gmm.weights_[i]
        
    y0 = y_pdf.sum(axis=0)
    y1 = y_cdf.sum(axis=0)
    x_peak = x0[np.argmax(y0)]
    
    try:
        x_left = x0[(y0 < threshold) & (x0 < x_peak)].max()
    except:
        sc.logging.warning('Failed to find lower bound, using min value instead.')
        x_left = x0.min()
        
    try:
        x_right = x0[(y0 < threshold) & (x0 > x_peak)].min()
    except:
        sc.logging.warning('Failed to find upper bound, using max value instead.')
        x_right = x0.max()
        
    return x_left, x_right, gmm

def auto_qc_filter(
        adata,
        metrics = ['n_counts', 'n_genes', 'percent_mito', 'percent_ribo', 'percent_hb', 'percent_top50'],
        min_count = 1000, min_gene = 500, min_mito = 0.01, max_mito = 20, min_ribo = 0, max_ribo = 100):
          
    k_pass = np.ones(adata.n_obs).astype(bool)

    if 'n_counts' in metrics:
        x_low, x_high, _ = fit_gaussian(adata.obs['log1p_n_counts'].values, xmin = np.log1p(min_count))
        min_count = int(np.expm1(x_low))
        max_count = int(np.expm1(x_high))
        k_count = (adata.obs['n_counts'] >= min_count) & (adata.obs['n_counts'] <= max_count)
        sc.logging.warning(f'n_counts: [{min_count}, {max_count}], {k_count.sum()} pass')
        k_pass = k_pass & k_count

    if 'n_genes' in metrics:
        x_low, x_high, _ = fit_gaussian(adata.obs['log1p_n_genes'].values, xmin=np.log1p(min_gene))
        min_gene = int(np.expm1(x_low))
        max_gene = int(np.expm1(x_high))
        k_gene = (adata.obs['n_genes'] >= min_gene) & (adata.obs['n_genes'] <= max_gene)
        sc.logging.warning(f'n_genes: [{min_gene}, {max_gene}], {k_gene.sum()} pass')
        k_pass = k_pass & k_gene

    if 'percent_mito' in metrics:
        max_mito = 20
        if (adata.obs['percent_mito'].values > 0).sum() > 0:
            x_low, x_high, _ = fit_gaussian(np.log1p(adata.obs['percent_mito'].values), xmin=np.log1p(min_mito), xmax=np.log1p(max_mito))
            max_mito = np.expm1(x_high)
        k_mito = (adata.obs['percent_mito'] <= max_mito)
        sc.logging.warning(f'percent_mito: [0, {max_mito}], {k_mito.sum()} pass')
        k_pass = k_pass & k_mito

    if 'percent_ribo' in metrics:
        x_low, x_high, _ = fit_gaussian(np.log1p(adata.obs['percent_ribo'].values), xmin=np.log1p(min_ribo), xmax=np.log1p(max_ribo))
        min_ribo = np.expm1(x_low)
        max_ribo = np.expm1(x_high)
        k_ribo = (adata.obs['percent_ribo'] >= min_ribo) & (adata.obs['percent_ribo'] <= max_ribo)
        sc.logging.warning(f'percent_ribo: [{min_ribo}, {max_ribo}], {k_ribo.sum()} pass')
        k_pass = k_pass & k_ribo

    if 'percent_hb' in metrics:
        max_hb = 1.0
        k_hb = adata.obs['percent_hb'] <= max_hb
        sc.logging.warning(f'percent_hb: [0, 10], {k_hb.sum()} pass')
        k_pass = k_pass & k_hb

    if 'percent_top50' in metrics: # <-- something weird going on here. Do I need to get it to work though?
        x_low, x_high, _ = fit_gaussian(adata.obs['percent_top50'].values)
        max_top50 = x_high
        min_top50 = x_low
        k_top50 = (adata.obs['percent_top50'] <= max_top50) & (adata.obs['percent_top50'] >= min_top50)
        sc.logging.warning(f'percent_top50: [{min_top50}, {max_top50}], {k_top50.sum()} pass')
        k_pass = k_pass & k_top50

    sc.logging.warning(f'{k_pass.sum()} pass')
    return k_pass

# computing 10th and 90th percentile per column <---
def trim_col(col):
  if col.nonzero()[0].shape[0] > 0:
    lower, upper = np.percentile(col[col.nonzero()], q=[10,90], axis = 1)
    trim_indices = col.nonzero()[0][(np.asarray(col[col.nonzero()] > upper) | np.asarray(col[col.nonzero()] < lower)).flatten()]
  else:
    trim_indices = []
  return(trim_indices)


def trimmed_means(filtered, cluster_numbers):
  # counting number of zeros per gene in each cluster
  col_num_zeros = [filtered[filtered.obs.cluster_number.isin([clust]),:].X.shape[0] - filtered[filtered.obs.cluster_number.isin([clust]),:].X.getnnz(axis=0) for clust in cluster_numbers]
  for i in range(0, filtered.X.shape[1], 1):
    trim_indices = trim_col(filtered.X.getcol(i))
    if len(trim_indices) > 0:
      filtered.X[trim_indices,i] = 0
  # omitting explicit 0 values
  filtered.X.eliminate_zeros()
  # counting number of nonzeros per gene in each cluster
  col_num_nonzeros = [filtered[filtered.obs.cluster_number.isin([clust]),:].X.getnnz(axis=0) for clust in cluster_numbers]
  # pseudobulking
  numerators = [np.asarray(filtered[filtered.obs.cluster_number.isin([clust]),:].X.sum(axis=0)).flatten() for clust in cluster_numbers]
  denominators = [col_num_zeros[i] + col_num_nonzeros[i] for i in range(0, cluster_numbers.shape[0], 1)]
  cluster_pseudobulks = [numerators[i]/denominators[i] for i in range(0, cluster_numbers.shape[0], 1)]
  return(cluster_pseudobulks, col_num_nonzeros)

def trimmed_counts(filtered, gene):
  gene_specific = filtered[:,gene]
  trim_indices = trim_col(gene_specific.X.getcol(0))
  if len(trim_indices) > 0:
    gene_specific.X[trim_indices, 0] = 0
  gene_specific.X.eliminate_zeros()
  rows, cols = gene_specific.X.nonzero()
  gene_specific = gene_specific[rows, 0]
  return(gene_specific)

def simple_default_pipeline(adata, filter_kw={}):
  
  calculate_qc(adata)
  k_cell = auto_qc_filter(adata, **filter_kw)
  adata = adata[k_cell, :].copy()
  # adata.var['n_counts'] = adata.X.sum(axis = 0)#.A1
  # adata.var['n_genes'] = (adata.X > 0).sum(axis = 0)#.A1
  # k_gene = adata.var['n_genes'] >= 3
  # adata = adata[:, k_gene].copy()

  sc.pp.normalize_total(adata, target_sum=1e4)
  sc.pp.log1p(adata)

  return adata

database = sys.argv[1]
filename = sys.argv[2]
output_file = sys.argv[3]

pseudobulk_filename = output_file.replace('.h5ad','_pseudobulk.h5ad');

custom_clustering_file = None
tissue_annotation = "no-tissue"

if len(sys.argv) > 4:
  custom_clustering_file = sys.argv[4]
  tissue_annotation = sys.argv[5]

workdir = tempfile.mkdtemp()

tar = tarfile.open(filename, "r:gz")
tar.extract('genes.tsv',workdir)
tar.extract('barcodes.tsv',workdir)
tar.extract('matrix.mtx',workdir)
tar.close()

matrixdata = sc.read_mtx(
  filename = os.path.join(workdir,'matrix.mtx'),  
  dtype = 'float32').transpose()

matrixdata.var_names = pd.read_csv(os.path.join(workdir,'genes.tsv'), sep='\t', header=None, names=['gene'])['gene'].to_numpy()
matrixdata.obs_names = pd.read_csv(os.path.join(workdir,'barcodes.tsv'), sep='\t', header=None, names=['barcode'])['barcode'].to_numpy()

if custom_clustering_file != None:
  h = ['barcode', 'celltype','cluster_number']
  
  cluster_info = pd.read_csv(custom_clustering_file, sep='\t', header=None, names=h)
  filtered = matrixdata[cluster_info['barcode']]
  
  filtered.obs['celltype'] = cluster_info['celltype'].to_numpy()
  filtered.obs['cluster_number'] = cluster_info['cluster_number'].to_numpy()
  
  sc.pp.normalize_total(filtered, target_sum=1e4)
  
  cluster_numbers = np.unique(cluster_info['cluster_number'].to_numpy())
  cluster_ids = [ tissue_annotation+"_"+("_cluster_".join(x)) for x in list(zip(cluster_info['celltype'].to_numpy(),cluster_info['cluster_number'].to_numpy().astype('str')))]
  
  indexes = np.unique(cluster_ids, return_index=True)[1]
  
  cluster_ids = [cluster_ids[index] for index in sorted(indexes)]
  
  hgnc_only = np.array([ geneid.split('_EN')[0] for geneid in matrixdata.var_names ]).astype('str')
  
  unique_celltypes = np.array([ cluster_info['celltype'][index] for index in sorted(indexes) ]).astype('str')
    
  cluster_sizes = np.array([ np.count_nonzero(filtered.obs.cluster_number.isin([clust])) for clust in cluster_numbers])
  # filtering 10-90 percentile outliers on each gene before computing pseudobulk average
  cluster_pseudobulks, cluster_specific_num_nonzero_valued_genes = trimmed_means(filtered, cluster_numbers)
  pseudobulks = pd.DataFrame(cluster_pseudobulks).T
  pseudopresence = pd.DataFrame(cluster_specific_num_nonzero_valued_genes).T
  # preparing pseudobulk anndata object
  obsdata = pd.DataFrame(matrixdata.var_names)
  obsdata.columns = ['gene']
  pseudobulk_anndata = anndata.AnnData(X=pseudobulks, obs=obsdata)
  sc.pp.log1p(pseudobulk_anndata)
  # writing pseudobulk anndata to h5ad 
  pseudobulk_anndata.uns['tissue'] = tissue_annotation
  pseudobulk_anndata.obsm['hgnc'] = hgnc_only
  pseudobulk_anndata.obsm['gene'] = np.array(matrixdata.var_names).astype('str')
  pseudobulk_anndata.varm['celltype'] = unique_celltypes
  pseudobulk_anndata.varm['cluster_number'] = cluster_numbers
  pseudobulk_anndata.varm['cluster_size'] = cluster_sizes
  pseudobulk_anndata.write(pseudobulk_filename)
  # writing pseudobulk pandas to csv
  pseudobulks.columns = cluster_ids
  pseudobulks.insert(0, "hgnc", hgnc_only, True)
  pseudobulks.insert(0, "gene", matrixdata.var_names, True)
  pseudobulks.to_csv(pseudobulk_filename.replace('.h5ad','.tsv'), sep='\t', quoting=csv.QUOTE_NONE, na_rep='NaN', index=False)
  # writing pseudopresence pandas to csv
  pseudopresence.columns = cluster_ids
  pseudopresence.insert(0, "hgnc", hgnc_only, True)
  pseudopresence.insert(0, "gene", matrixdata.var_names, True)
  pseudopresence.to_csv(pseudobulk_filename.replace('_pseudobulk.h5ad','_pseudopresence.tsv'), sep='\t', quoting=csv.QUOTE_NONE, na_rep='NaN', index=False)
    
else:
  filtered = simple_default_pipeline(
    adata = matrixdata, 
    filter_kw = {'metrics':['n_counts', 'n_genes']}) # 'percent_top50']})

filtered.write(output_file)

shutil.rmtree(workdir)

