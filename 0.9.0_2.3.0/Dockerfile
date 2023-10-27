#
# Copyright (2023) The Delta Lake Project Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# ------------------------------------------------
# Dockerfile for Delta Lake quickstart
# ------------------------------------------------

# This docker image uses the official Docker image of [OSS] Apache Spark v3.3.2 as the base container
# Note: Python version in this image is 3.9.2 and is available as `python3`.
ARG BASE_CONTAINER=apache/spark-py:v3.3.2
FROM $BASE_CONTAINER as spark
FROM spark as delta

# Authors (add your name when updating the Dockerfile)
LABEL authors="Prashanth Babu,Denny Lee,Andrew Bauman"

# Docker image was created and tested with the versions of following packages.
USER root
ARG DELTA_SPARK_VERSION="2.3.0"
ARG DELTALAKE_VERSION="0.9.0"
ARG JUPYTERLAB_VERSION="3.6.3"
ARG PANDAS_VERSION="1.5.3"
ARG ROAPI_VERSION="0.9.0"

# We are explicitly pinning the versions of various libraries which this Docker image runs on.
RUN pip install --quiet --no-cache-dir delta-spark==${DELTA_SPARK_VERSION} \
deltalake==${DELTALAKE_VERSION} jupyterlab==${JUPYTERLAB_VERSION} pandas==${PANDAS_VERSION} roapi==${ROAPI_VERSION}


# Environment variables
FROM delta as startup
ARG NBuser=NBuser
ARG GROUP=NBuser
ARG WORKDIR=/opt/spark/work-dir
ENV DELTA_PACKAGE_VERSION=delta-core_2.12:${DELTA_SPARK_VERSION}

# OS Installations Configurations
RUN groupadd -r ${GROUP} && useradd -r -m -g ${GROUP} ${NBuser}
RUN apt -qq update
RUN apt -qq -y install vim curl

# Configure ownership
COPY --chown=${NBuser} startup.sh "${WORKDIR}"
COPY --chown=${NBuser} quickstart.ipynb "${WORKDIR}"
COPY --chown=${NBuser} rs/ "${WORKDIR}/rs"
RUN chown -R ${NBuser}:${GROUP} /home/${NBuser}/ \
&& chown -R ${NBuser}:${GROUP} ${WORKDIR}

# Rust install
USER ${NBuser}
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN source "$HOME/.cargo/env"

# Establish entrypoint
ENTRYPOINT ["bash", "startup.sh"]