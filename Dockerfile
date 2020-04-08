FROM openjdk:8-jre-slim

ARG PULSAR_MIRROR="https://archive.apache.org/dist/pulsar"
ARG PULSAR_VERSION="2.5.0"
ARG PULSAR_BIN="${PULSAR_MIRROR}/pulsar-${PULSAR_VERSION}/apache-pulsar-${PULSAR_VERSION}-bin.tar.gz"
USER root

RUN apt-get update \
     && apt-get install -y netcat dnsutils less procps iputils-ping \
                 python2.7 python-setuptools python-yaml python-kazoo \
                 python3.7 python3-setuptools python3-yaml python3-kazoo \
                 libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev \
                 curl \
                 vim \
                 wget \
                 less \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/*

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python2.7 get-pip.py
RUN python3.7 get-pip.py

ENV PULSAR_HOME /pulsar
ENV PULSAR_USER pulsar

RUN useradd \
        --create-home \
        --home-dir ${PULSAR_HOME} \
        --shell /bin/bash \
        $PULSAR_USER

RUN mkdir -p $PULSAR_HOME && \
    wget --quiet $PULSAR_BIN && \
    tar xzf apache-pulsar-${PULSAR_VERSION}-bin.tar.gz && \
    rm -rf apache-pulsar-${PULSAR_VERSION}-bin.tar.gz && \
    mv apache-pulsar-${PULSAR_VERSION}/* $PULSAR_HOME && \
    rm -rf apache-pulsar-${PULSAR_VERSION} && \
    mkdir -p $PULSAR_HOME/custom && \
    chown -R ${PULSAR_USER}:${PULSAR_USER} $PULSAR_HOME

USER $PULSAR_USER

CMD ["launcher", "run"]

