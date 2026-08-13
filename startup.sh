#!/bin/bash

source "$HOME/.cargo/env"

export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='lab --ip=0.0.0.0'
export DELTA_SPARK_VERSION='4.2.0'
export SPARK_VERSION='4.1'
export DELTA_PACKAGE_VERSION=delta-spark_${SPARK_VERSION}_2.13:${DELTA_SPARK_VERSION}
export MAVEN_PROXY_URL=${MAVEN_PROXY_URL:-https://repo.1.maven.org/maven2/}

$SPARK_HOME/bin/pyspark --packages io.delta:${DELTA_PACKAGE_VERSION} \
  --conf "spark.jars.repositories=${MAVEN_PROXY_URL}" \
  --conf "spark.driver.extraJavaOptions=-Divy.cache.dir=/tmp -Divy.home=/tmp -Dio.netty.tryReflectionSetAccessible=true" \
  --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" \
  --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
