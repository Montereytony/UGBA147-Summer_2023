#
# Take ownership of the mess that follows
#
ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM $BASE_CONTAINER
ARG OWNER=montereytony@gmail.com

#Let's define this parameter to Not install jupyter lab instead of the default juyter notebook command so we don't have to use it when running the container with the option -e
ENV JUPYTER_ENABLE_LAB=no

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
USER root
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen &&\
	locale-gen en_US.utf8 && \
	/usr/sbin/update-locale  LANG=en_US.UTF-8


RUN apt-get update --yes && sudo apt-get -y  dist-upgrade && \
    apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    fftw-dev \
    r-cran-fftw  libsndfile1-dev libfftw3-dev libsndfile1 \
    software-properties-common \
    build-essential \
    fonts-dejavu \
    unixodbc \
    unixodbc-dev \
    r-cran-rodbc \
    gfortran \
    gcc \
    pkg-config \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    hicolor-icon-theme \
    libcanberra-gtk* \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    libpango1.0-0 \
    libpulse0 \
    libv4l-0 \
    zlib1g-dev zlib1g \
    r-cran-rgl \
    freeglut3-dev \
    libgl1-mesa-dev libglu1-mesa-dev \
    libglu1-mesa-dev freeglut3-dev mesa-common-dev \
    fonts-symbola \
    --no-install-recommends \
    && curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y \
    --no-install-recommends \
    google-chrome-stable  &&\
    wget https://downloads.vivaldi.com/stable/vivaldi-stable_5.5.2805.35-1_amd64.deb  &&\
    apt-get update && apt-get install -y ./vivaldi-stable_5.5.2805.35-1_amd64.deb && rm -rf /var/lib/apt/lists/* && \
    echo CHROMOTE_CHROME=/usr/bin/vivaldi >> .Renviron && \
    apt-get purge --auto-remove -y curl && \
    rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# Prof Huntsinger asked for R 4.2.2
ENV R_BASE_VERSION 4.2.2
RUN pip install notebook==5.7.10 retrolab && \
    mamba install --yes \
    r-base=${R_BASE_VERSION} \
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
    'r-htmlwidgets'  \
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
    'r-htmltools'  \
    'r-igraph' \
    'r-IRdisplay' \
    'r-kableExtra' \
    'r-kknn' \
    'r-ks' \
    'r-knitr'  \
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
    'r-webshot2'


RUN mamba install --yes -c conda-forge r-webshot  uwsgi nbclassic && \
    mamba install --yes -c r r-simmer r-remotes r-stringi  nbgitpuller r-ggnewscale r-leaflet \
                       r-rglwidget r-sigmoid r-imager && \
    Rscript -e 'remotes::install_github("ShotaOchi/imagerExtra")' && \
    Rscript -e 'remotes::install_github("r-simmer/simmer.plot")' && \
    Rscript -e 'devtools::install_github("ShotaOchi/imagerExtra")' && \
    Rscript -e 'remotes::install_github("dmurdoch/rgl")' &&\
    mamba clean --all -f -y

USER root
RUN fix-permissions "${CONDA_DIR}"  &&\
    fix-permissions /home/jovyan
USER ${NB_UID}
#
#
# The below is a mess, I kept adding lines to get the nbextensions to work.
# turned out I had to go back to a version 6 notebook.
#
COPY custom.css /opt/conda/lib/python3.10/site-packages/jupyter_core/tests/dotipython/profile_default/static/custom/custom.css
COPY custom.css /opt/conda/lib/python3.10/site-packages/jupyter_core/tests/dotipython_empty/profile_default/static/custom/custom.css
COPY custom.css /opt/conda/lib/python3.10/site-packages/nbclassic/static/custom/custom.css

RUN export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$JAVA_LD_LIBRARY_PATH && \
    mkdir -p /home/jovyan/.local  /home/jovyan/.local/share \
    /home/jovyan/.local/share/jupyter/ /home/jovyan/.local/share/jupyter/nbextensions/ && \
    pip install jupyter_contrib_nbextensions && \
    pip install jupyter_nbextensions_configurator &&\
    jupyter nbextensions_configurator enable --user &&\
    jupyter contrib nbextension install --user && \
    jupyter nbextension install --sys-prefix --py jupyter_nbextensions_configurator --overwrite  && \
    jupyter nbextension enable  --sys-prefix --py jupyter_nbextensions_configurator  && \
    jupyter serverextension enable --sys-prefix --py jupyter_nbextensions_configurator  && \
    jupyter nbextension enable spellchecker/main &&\
    jupyter nbextension enable codefolding/main &&\
    jupyter nbextension enable varInspector/main &&\
    jupyter nbextension enable toc2/main &&\
    jupyter nbextension enable execute_time/ExecuteTime &&\
    jupyter nbextension enable hide_input/main &&\
    jupyter nbextension enable splitcell/splitcell &&\
    jupyter nbextension enable code_prettify/code_prettify

COPY fixer.sh /tmp
