pip install jupyter_nbextensions_configurator
jupyter nbextension install --sys-prefix --py jupyter_nbextensions_configurator --overwrite
jupyter nbextension enable --sys-prefix --py jupyter_nbextensions_configurator
jupyter serverextension enable --sys-prefix --py jupyter_nbextensions_configurator
jupyter contrib nbextensions install --user
