#!/usr/bin/env bash
DRY_RUN=0  # change to 1 to just print the changes
mkdir /usr/local/share/jupyter
chown jovyan /usr/local/share/jupyter
SITE_PACKAGES_DIR=$(python -c 'import site; print(site.getsitepackages()[0])')

patch-template-paths-with-backup() {
    _target_relpath=$1
    _target_file=$SITE_PACKAGES_DIR/$_target_relpath
    _backup_file=$_target_file.orig
    if [ -e $_backup_file ]; then
        echo "WARN: $_backup_file exists; assuming patch is already completed"
        return
    fi

    SED_STRING='s/\btemplate_path\b/template_paths/g'

    if [ $DRY_RUN -eq 1 ]; then
        cat $_target_file |
            sed $SED_STRING |
            diff -Naur $_target_file -
        read
    else
        set -x
        mv $_target_file $_backup_file
        set +x
        cat $_backup_file |
            sed $SED_STRING |
            cat > $_target_file
    fi
}

FILES_TO_CONVERT=(
    jupyter_contrib_nbextensions/config_scripts/highlight_html_cfg.py
    jupyter_contrib_nbextensions/config_scripts/highlight_latex_cfg.py
    jupyter_contrib_nbextensions/install.py
    jupyter_contrib_nbextensions/nbconvert_support/exporter_inliner.py
    jupyter_contrib_nbextensions/nbconvert_support/toc2.py
    jupyter_contrib_nbextensions/nbextensions/runtools/readme.md
    jupyter_core/tests/dotipython_empty/profile_default/ipython_nbconvert_config.py
    latex_envs/latex_envs.py
);

for file_to_convert in ${FILES_TO_CONVERT[@]}; do
    echo $file_to_convert
    patch-template-paths-with-backup $file_to_convert
done
