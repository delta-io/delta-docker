#!/bin/bash

source "$HOME/.cargo/env"

export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='lab --ip=0.0.0.0'
export DELTA_SPARK_VERSION='4.4.0'
export SPARK_VERSION='4.2'
export DELTA_PACKAGE_VERSION=delta-spark_${SPARK_VERSION}_2.13:${DELTA_SPARK_VERSION}
export MAVEN_PROXY_URL=${MAVEN_PROXY_URL:}

REPOSITORIES_CONF=()
if [ -n "$MAVEN_PROXY_URL" ]; then
  REPOSITORIES_CONF=(--conf "spark.jars.repositories=${MAVEN_PROXY_URL}")
fi

$SPARK_HOME/bin/pyspark --packages io.delta:${DELTA_PACKAGE_VERSION} \
  "${REPOSITORIES_CONF[@]}" \
  --conf "spark.driver.extraJavaOptions=-Divy.cache.dir=/tmp -Divy.home=/tmp -Dio.netty.tryReflectionSetAccessible=true" \
  --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" \
  --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
