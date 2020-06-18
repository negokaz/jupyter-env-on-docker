#!/bin/bash -e

readonly config_tmp="$(mktemp --directory)"

function main {
    disable_authentication
    install_template_extension
    install_lsp

    cat "${config_tmp}"/* > "${HOME}/.jupyter/jupyter_notebook_config.py"
    echo '= [jupyter_notebook_config.py] =============================================='
    cat "${HOME}/.jupyter/jupyter_notebook_config.py"
    echo '============================================================================='

    exec /usr/local/bin/start.sh jupyter "$@"
}

function disable_authentication {
    add_jupyter_notebook_config "
        c.NotebookApp.token     = ''
        c.NotebookApp.password  = ''
    "
}

function install_template_extension {
    if pip_install_if_not_installed jupyterlab_templates
    then
        jupyter labextension install jupyterlab_templates
        jupyter serverextension enable --py jupyterlab_templates
    fi
    add_jupyter_notebook_config "
        c.JupyterLabTemplates.template_dirs       = ['/home/jovyan/notebook_templates']
        c.JupyterLabTemplates.include_default     = False
        c.JupyterLabTemplates.include_core_paths  = False
    "
}

function install_lsp {
    if pip_install_if_not_installed jupyter-lsp python-language-server[all]
    then
        jupyter labextension install @krassowski/jupyterlab-lsp
    fi
}

function pip_install_if_not_installed {
    if ! pip show --quiet "$@"
    then
        pip install "$@"
        return 0
    else
        return 1
    fi
}

function add_jupyter_notebook_config {
    echo "$1" | sed -E -e 's/^ *//g' -e '/^ *$/d' > "$(mktemp --tmpdir="${config_tmp}")"
}

trap on_exit EXIT

function on_exit {
    rm -rf "${config_tmp}"
}

main "$@"