#
# Copyright (2023) The Delta Lake Project Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
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

# This Docker image uses the official Docker image of [OSS] Apache Spark v4.0.0 as the base container
# Note: Python version in this image is 3.9.2 and is available as `python3`.
# Note: PySpark v4.0.0 (https://spark.apache.org/docs/latest/api/python/getting_started/install.html#dependencies)

ARG BASE_CONTAINER=apache/spark:4.1.1-scala2.13-java21-python3-r-ubuntu
FROM $BASE_CONTAINER AS spark
FROM spark AS delta

# Authors (add your name when updating the Dockerfile)
LABEL authors="Prashanth Babu, Denny Lee, Andrew Bauman, Scott Haines, Tristen Wentling"

# Docker image was created and tested with the following versions of packages.
USER root
ARG DELTA_SPARK_VERSION="4.1.0"
# Note: for 3.0.0 https://pypi.org/project/deltalake/
ARG DELTALAKE_VERSION="1.4.2"
ARG JUPYTERLAB_VERSION="4.4.6"
# requires py4j>=0.10.9.7, pyarrow>=16
ARG POLARS_VERSION="1.38.1"
ARG PYARROW_VERSION="23.0.1"
ARG ROAPI_VERSION="0.12.6"

# We are explicitly pinning the versions of various libraries which this Docker image runs on.
RUN pip install --quiet --no-cache-dir delta-spark==${DELTA_SPARK_VERSION} \
    deltalake==${DELTALAKE_VERSION} jupyterlab==${JUPYTERLAB_VERSION} pyarrow==${PYARROW_VERSION} \
    polars==${POLARS_VERSION} roapi==${ROAPI_VERSION}


# Environment variables
FROM delta AS startup
ARG NBuser=NBuser
ARG GROUP=NBuser
ARG WORKDIR=/opt/spark/work-dir
ENV DELTA_PACKAGE_VERSION=delta-spark_2.13:${DELTA_SPARK_VERSION}

# OS Installations Configurations
RUN groupadd -r ${GROUP} && useradd -r -m -g ${GROUP} ${NBuser}
RUN apt -qq update
RUN apt -qq -y install vim curl tree

# Configure ownership
COPY --chown=${NBuser} startup.sh "${WORKDIR}"
COPY --chown=${NBuser} quickstart.ipynb "${WORKDIR}"
COPY --chown=${NBuser} rs/ "${WORKDIR}/rs"
RUN chown -R ${NBuser}:${GROUP} /home/${NBuser}/ \
&& chown -R ${NBuser}:${GROUP} ${WORKDIR}

# Rust install
USER ${NBuser}
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
# moved the source command into the bash process in the entrypoint startup.sh
#RUN source "$HOME/.cargo/env"

# Establish entrypoint
ENTRYPOINT ["bash", "startup.sh"]