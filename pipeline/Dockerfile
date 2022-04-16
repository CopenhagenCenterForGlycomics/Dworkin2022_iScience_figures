FROM r-base:3.6.1

# installing python3.6
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	gcc-9-base libgcc-9-dev libc6-dev \
	build-essential \
	libpq-dev python3.6 python3-pip python3-setuptools python3-dev

# installing remotes R package
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"

# analysis folder hierarchy
COPY results /results
WORKDIR /results

# installing python libraries
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

# installing r libraries
COPY requirements.R requirements.R
RUN R -e "source('requirements.R')"

COPY rdata_to_matrixmarket_panglaodb.sh /usr/local/bin

COPY rdata_to_matrixmarket_wrapper_panglaodb.sh /usr/local/bin

COPY matrixmarket_to_h5ad_wrapper_panglaodb.sh /usr/local/bin

COPY matrixmarket_to_processed_h5ad_scanpy_panglaodb.py /usr/local/bin

COPY h5ad_to_matrixmarket_tabuladb.sh /usr/local/bin

COPY h5ad_to_matrixmarket_wrapper_tabuladb.sh /usr/local/bin

COPY matrixmarket_to_h5ad_wrapper_tabuladb.sh /usr/local/bin

COPY matrixmarket_to_processed_h5ad_scanpy_tabuladb.py /usr/local/bin

COPY h5ad_to_rds.R /usr/local/bin

COPY perform_preprocessing_pipeline.sh /usr/local/bin

COPY generate_data.R /usr/local/bin

COPY generate_main_figures.R /usr/local/bin

COPY generate_supplementary_figures.R /usr/local/bin

COPY generate_supplementary_tables.R /usr/local/bin

COPY perform_figure_generation_pipeline.sh /usr/local/bin

ENTRYPOINT ["/usr/local/bin/perform_figure_generation_pipeline.sh"]

