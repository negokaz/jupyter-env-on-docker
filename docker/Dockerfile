FROM jupyter/minimal-notebook:latest

USER root

RUN set -xe; \
    : add package; \
    apt-get install -y bash; \
    : done

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN set -xe; \
    chmod +x /usr/local/bin/entrypoint.sh; \
    : done

USER $NB_UID

WORKDIR ${HOME}/work
EXPOSE 8888

VOLUME ["/home/jovyan/", "/tmp/"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["lab"]
