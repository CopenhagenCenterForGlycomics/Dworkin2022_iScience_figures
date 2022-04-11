FROM python:3.8-slim

RUN apt-get update && apt-get install --no-install-recommends -y wget r-base-core r-cran-matrix r-cran-bit64 libhdf5-dev build-essential && rm -rf /var/lib/apt/lists/*

RUN pip3 install -r requirements.txt

ENV RENV_VERSION 0.15.3
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

COPY results /results

WORKDIR /results

COPY renv.lock renv.lock

RUN R -e 'renv::restore()'

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

