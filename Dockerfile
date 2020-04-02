FROM openjdk:8-jre-slim

ARG MIRROR="https://repo1.maven.org/maven2/com/facebook/presto"
ARG PRESTO_VERSION="0.233.1"
ARG PRESTO_BIN="${MIRROR}/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz"
ARG PRESTO_CLI_BIN="${MIRROR}/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar"
ARG PULSAR_MIRROR="https://archive.apache.org/dist/pulsar"
ARG PULSAR_VERSION="2.5.0"
ARG PRESTO_PULSAR_PLUGIN="${PULSAR_MIRROR}/pulsar-${PULSAR_VERSION}/apache-pulsar-${PULSAR_VERSION}-bin.tar.gz"

USER root

RUN apt-get update \
 && apt-get install -y --allow-unauthenticated \
      curl \
      wget \
      less \
      vim \
      python3 \
      python3-pip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && ln -s /usr/bin/python3 /usr/bin/python \
 && pip3 install \
      jinja2

ENV PRESTO_HOME /presto
ENV PRESTO_USER presto
ENV PRESTO_CONF_DIR ${PRESTO_HOME}/etc
ENV PATH $PATH:$PRESTO_HOME/bin

RUN useradd \
        --create-home \
        --home-dir ${PRESTO_HOME} \
        --shell /bin/bash \
        $PRESTO_USER

RUN mkdir -p $PRESTO_HOME && \
    wget --quiet $PRESTO_BIN && \
    tar xzf presto-server-${PRESTO_VERSION}.tar.gz && \
    rm -rf presto-server-${PRESTO_VERSION}.tar.gz && \
    mv presto-server-${PRESTO_VERSION}/* $PRESTO_HOME && \
    rm -rf presto-server-${PRESTO_VERSION} && \
    mkdir -p ${PRESTO_CONF_DIR}/catalog/ && \
    mkdir -p ${PRESTO_HOME}/data && \
    wget --quiet $PRESTO_PULSAR_PLUGIN && \
    tar xzf apache-pulsar-${PULSAR_VERSION}-bin.tar.gz && \
    rm -rf apache-pulsar-${PULSAR_VERSION}-bin.tar.gz && \
    mv apache-pulsar-${PULSAR_VERSION}/lib/presto/plugin/pulsar-presto-connector $PRESTO_HOME/plugin/ && \
    rm -rf apache-pulsar-${PULSAR_VERSION} && \
    cd ${PRESTO_HOME}/bin && \
    wget --quiet ${PRESTO_CLI_BIN} && \
    mv presto-cli-${PRESTO_VERSION}-executable.jar presto && \
    chmod +x presto && \
    chown -R ${PRESTO_USER}:${PRESTO_USER} $PRESTO_HOME

COPY template_configs ${TEMPLATE_DEFAULT_DIR}
COPY presto-entrypoint.py ${PRESTO_HOME}

USER $PRESTO_USER

WORKDIR ${PRESTO_HOME}

EXPOSE 8080

CMD ["python3", "presto-entrypoint.py"]