ARG OWNER=jupyter
ARG BASE_CONTAINER=$OWNER/minimal-notebook
FROM $BASE_CONTAINER

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

ENV R_BASE_VERSION 4.2.2

RUN apt update && sudo apt -y  dist-upgrade

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    software-properties-common \
    build-essential \
    fonts-dejavu \
    unixodbc \
    unixodbc-dev \
    r-cran-rodbc \
    gfortran \
    gcc \
    pkg-config \
    zlib1g-dev zlib1g

#RUN wget https://www.python.org/ftp/python/3.11.2/Python-3.11.2.tgz  && \
#    tar  xzf Python-3.11.2.tgz  && \
#    cd Python-3.11.2 && ./configure --enable-optimizations  && \
#    make  && make install && cd ..  && rm -rf Python-3.11.*
    

USER ${NB_UID}

RUN conda update -n base -c defaults conda && \
    mamba install --yes \
    'r-base' \
    'r-caret' \
    'r-crayon' \
    'r-devtools' \
    'r-e1071' \
    'r-forecast' \
    'r-hexbin' \
    'r-htmltools' \
    'r-htmlwidgets' \
    'r-irkernel' \
    'r-nycflights13' \
    'r-randomforest' \
    'r-rcurl' \
    'r-rmarkdown' \
    'r-rodbc' \
    'r-rsqlite' \
    'r-shiny' \
    'r-tidymodels' \
    'r-tidyverse' \
    'gcc_linux-64' \
    'gfortran_linux-64' \
    'r-essentials' \
    'r-htmlwidgets' \
    'r-gridExtra' \
    'r-e1071' \
    'r-rgl' \
    'r-xlsxjars' \
    'r-xlsx' \
    'r-aer ' \
    'r-png' \
    'r-rJava' \
    'r-devtools' \
    'r-digest' \
    'r-evaluate' \
    'r-memoise ' \
    'r-withr ' \
    'r-irdisplay' \
    'r-r6 ' \
    'r-base' \
    'r-lightgbm' \
    'r-plyr' \
    'r-dplyr' \
    'r-base64enc' \
    'r-caret' \
    'r-colorspace' \
    'r-e1071' \
    'r-entropy' \
    'r-fastDummies' \
    'r-ggdendro' \
    'r-GGally' \
    'r-ggplot2' \
    'r-gtools' \
    'r-ggwordcloud' \
    'r-gridExtra' \
    'r-htmltools' \
    'r-igraph' \
    'r-IRdisplay' \
    'r-kableExtra' \
    'r-kknn' \
    'r-ks' \
    'r-knitr' \
    'r-lubridate' \
    'r-MASS' \
    'r-mclust' \
    'r-mvtnorm' \
    'r-neuralnet' \
    'r-NLP' \
    'r-OpenImageR' \
    'r-pracma' \
    'r-polyclip' \
    'r-psych' \
    'r-qgraph' \
    'r-readxl' \
    'r-reshape2' \
    'r-rjson' \
    'r-rmarkdown' \
    'r-rpart' \
    'r-rpart.plot' \
    'r-stringr' \
    'r-SnowballC' \
    'r-tm' \
    'r-writexl'  \
    'numpy'\
    'statsmodels' \
    'unixodbc' 

RUN mamba install -c conda-forge r-webshot  uwsgi jupyter_contrib_nbextensions 
RUN mamba install -c r r-simmer r-remotes r-stringi  nbgrader nbgitpuller r-ggnewscale

RUN Rscript -e 'remotes::install_github("r-simmer/simmer.plot")'
USER root
RUN jupyter labextension install @jupyterlab/hub-extension && \
    jupyter nbextensions_configurator enable --sys-prefix  && \
    jupyter labextension enable --level=system nbgrader   && \
    jupyter server extension enable --system --py nbgrader && \
    pip install jupyterthemes  && \
    pip install --upgrade jupyterthemes  && \
    pip install jupyter_contrib_nbextensions  && \
    pip install RISE  && \
    jupyter-nbextension install rise --py --sys-prefix  && \
    jupyter-nbextension enable  rise --py --sys-prefix
ADD fixer.sh /tmp
ADD fix-permissions /tmp
RUN mamba clean --all -f -y && \
    bash /tmp/fixer.sh && \
    wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb && sudo dpkg -i nvim-linux64.deb && \
    chmod -R 775 "${CONDA_DIR}" && \
    chown -R ${NB_USER} "${CONDA_DIR}" && \
    chown -R ${NB_USER} "/home/${NB_USER}" &&\
    bash /tmp/fix-permissions 
 
USER ${NB_UID}
