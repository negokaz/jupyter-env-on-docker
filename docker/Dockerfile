FROM jupyter/minimal-notebook:latest

USER root

RUN set -xe; \
    : disable authentication; \
    echo "c.NotebookApp.token = ''"    >> ${HOME}/.jupyter/jupyter_notebook_config.py; \
    echo "c.NotebookApp.password = ''" >> ${HOME}/.jupyter/jupyter_notebook_config.py;

USER $NB_UID

WORKDIR ${HOME}/work
EXPOSE 8888

VOLUME ["/home/jovyan/"]

ENTRYPOINT ["/usr/local/bin/start.sh", "jupyter"]
CMD ["lab"]
