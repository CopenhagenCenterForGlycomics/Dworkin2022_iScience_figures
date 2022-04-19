FROM r-base:3.6.1

# installing python3.6
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	gcc-9-base libgcc-9-dev libc6-dev \
	build-essential \
	curl \
	libxml2-dev \
	libhdf5-dev \
	pandoc \
	libpq-dev python3.6 python3-pip python3-setuptools python3-dev

# installing remotes R package
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"

# analysis folder hierarchy
WORKDIR /home

# installing python libraries
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

# installing r libraries
COPY requirements.R requirements.R
RUN R -e "source('requirements.R')"

COPY download_scp.sh /usr/local/bin

COPY download_gtex.sh /usr/local/bin

COPY download_tcga.sh /usr/local/bin

COPY download_panglaodb.sh /usr/local/bin

COPY download_tabuladb.sh /usr/local/bin

COPY preprocess_pipeline_wrapper_scp.sh /usr/local/bin

COPY scanpy_normalization.py /usr/local/bin

COPY preprocess_pipeline_wrapper_panglaodb.sh /usr/local/bin

COPY rdata_to_matrixmarket_panglaodb.sh /usr/local/bin

COPY matrixmarket_to_processed_h5ad_scanpy_panglaodb.py /usr/local/bin

COPY preprocess_pipeline_wrapper_tabuladb.sh /usr/local/bin

COPY annotate_cells_tabuladb.sh /usr/local/bin

COPY h5ad_to_processed_h5ad_scanpy_tabuladb.py /usr/local/bin

COPY h5ad_to_rds.R /usr/local/bin

COPY preprocess_pipeline.sh /usr/local/bin

COPY reshape_data.sh /usr/local/bin

COPY generate_main_figures.sh /usr/local/bin

COPY generate_supplementary_figures.sh /usr/local/bin

COPY generate_supplementary_tables.sh /usr/local/bin

COPY main.sh /usr/local/bin

ENTRYPOINT ["/usr/local/bin/main.sh"]

