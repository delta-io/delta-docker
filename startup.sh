#!/bin/bash

source "$HOME/.cargo/env"

export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='lab --ip=0.0.0.0'

# Default Delta version; can be overridden by setting DELTA_SPARK_VERSION in the environment
: "${DELTA_SPARK_VERSION:=4.1.0}"

# Detect the Spark major.minor version from the running runtime (e.g. "4.1")
SPARK_FULL_VERSION=$("${SPARK_HOME}/bin/spark-submit" --version 2>&1 \
  | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
SPARK_MAJOR_MINOR=$(echo "${SPARK_FULL_VERSION}" | cut -d. -f1,2)

# Select the Delta Maven artifact that matches this Spark version.
# Spark 4.1 and 4.0 each publish a Spark-specific artifact; older releases use the generic one.
case "${SPARK_MAJOR_MINOR}" in
  4.1)
    DELTA_ARTIFACT="delta-spark_4.1_2.13"
    ;;
  4.0)
    DELTA_ARTIFACT="delta-spark_4.0_2.13"
    ;;
  *)
    DELTA_ARTIFACT="delta-spark_2.13"
    ;;
esac

export DELTA_PACKAGE_VERSION="${DELTA_ARTIFACT}:${DELTA_SPARK_VERSION}"

$SPARK_HOME/bin/pyspark --packages io.delta:${DELTA_PACKAGE_VERSION} \
  --conf "spark.driver.extraJavaOptions=-Divy.cache.dir=/tmp -Divy.home=/tmp -Dio.netty.tryReflectionSetAccessible=true" \
  --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" \
  --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
