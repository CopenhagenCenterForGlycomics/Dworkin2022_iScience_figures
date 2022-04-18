# import scanpy_scripts as ss
import sys
import numpy as np
import scanpy as sc
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

    if 'percent_top50' in metrics:
        x_low, x_high, _ = fit_gaussian(adata.obs['percent_top50'].values)
        max_top50 = x_high
        min_top50 = x_low
        k_top50 = (adata.obs['percent_top50'] <= max_top50) & (adata.obs['percent_top50'] >= min_top50)
        sc.logging.warning(f'percent_top50: [{min_top50}, {max_top50}], {k_top50.sum()} pass')
        k_pass = k_pass & k_top50

    sc.logging.warning(f'{k_pass.sum()} pass')
    return k_pass

def simple_default_pipeline(adata, filter_kw={}):
  
    calculate_qc(adata)
    k_cell = auto_qc_filter(adata, **filter_kw)
    adata = adata[k_cell, :].copy()
    adata.var['n_counts'] = adata.X.sum(axis = 0)#.A1
    adata.var['n_genes'] = (adata.X > 0).sum(axis = 0)#.A1
    k_gene = adata.var['n_genes'] >= 3
    adata = adata[:, k_gene].copy()

    sc.pp.normalize_total(adata, target_sum=1e4)
    sc.pp.log1p(adata)

    return adata

def perform_pipeline(infile, outfile):
  
  adata = sc.read_text(
    filename = filename,  
    delimiter = '\t', 
    first_column_names = True, 
    dtype = 'float32')
    
  fndata = simple_default_pipeline(
    adata = adata, 
    filter_kw = {'metrics':['n_counts', 'n_genes', 'percent_mito', 'percent_ribo', 'percent_hb']}) # 'percent_top50']})

  fndata.write_csvs(outfile, skip_data = False, sep = '\t')
  
  return

infile = '/preprocess/generate_model_data/chromium10x_replicate1_raw_umis.tsv'
outfile = '/preprocess/generate_model_data/chromium10x_replicate1_normalized_umis'
perform_pipeline(infile = infile, outfile = outfile)

infile = '/preprocess/generate_model_data/chromium10x_replicate2_raw_umis.tsv'
outfile = '/preprocess/generate_model_data/chromium10x_replicate2_normalized_umis'
perform_pipeline(infile = infile, outfile = outfile)


