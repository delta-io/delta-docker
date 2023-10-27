# Delta Lake Quickstart Docker

This folder contains instructions and materials to get new users started with Delta Lake and work through the quickstart materials using a self-contained Docker image.

> Note: The basic prerequisite for following along using Delta Lake Docker image is having Docker installed on your machine. Please follow the steps from the Docker website to install Docker locally. Based on your local machine operating system, please choose the appropriate option listed on the [Get Docker](https://docs.docker.com/get-docker/) page.

Follow the steps below to build an Apache Spark<sup>TM</sup> image with Delta Lake installed, run a container, and follow the quickstart in an interactive notebook or shell with any of the options like Python, PySpark, Scala Spark or even Rust.

1. [Working with Docker](#working-with-docker)
   1. [Build the image](#build-the-image)
   2. [Docker Hub](#docker-hub)
2. [Choose an interface](#choose-an-interface)

> Note: Python version available in this Docker image is 3.9.2 and is available as `python3`.

## Working with Docker

### Build the Image

1. Clone this repo
2. Navigate to the cloned folder
3. Navigate to the `quickstart_docker` folder
4. Open a bash shell (if on windows use git bash, WSL, or any shell configured for bash commands)
5. Execute the following from the `static/quickstart_docker` folder

   ```bash
   docker build -t delta_quickstart -f Dockerfile_delta_quickstart .
   ```

#### Build Entry Point

Your entry point for this locally built docker file is

```bash
docker run --name delta_quickstart --rm -it --entrypoint bash delta_quickstart
```

### Docker Hub

You can also download the image from DockerHub at [Delta Lake DockerHub](https://go.delta.io/dockerhub)

Note, there are different versions of the Delta Lake docker

| Tag               | Platform | Python | Rust   | Delta-Spark | Spark | JupyterLab | Pandas | ROAPI |
| ----------------- | -------- | ------ | ------ | ----------- | ----- | ---------- | ------ | ----- |
| 0.8.1_2.3.0       | amd64    | 0.8.1  | latest | 2.3.0       | 3.3.2 | 3.6.3      | 1.5.3  | 0.9.0 |
| 0.8.1_2.3.0_arm64 | arm64    | 0.8.1  | latest | 2.3.0       | 3.3.2 | 3.6.3      | 1.5.3  | 0.9.0 |
| 1.0.0_3.0.0       | amd64    | 0.12.0 | latest | 3.0.0       | 3.5.0 | 3.6.3      | 1.5.3  | 0.9.0 |
| 1.0.0_3.0.0_arm64 | arm64    | 0.12.0 | latest | 3.0.0       | 3.5.0 | 3.6.3      | 1.5.3  | 0.9.0 |
| latest            | amd64    | 0.12.0 | latest | 3.0.0       | 3.5.0 | 3.6.3      | 1.5.3  | 0.9.0 |
| latest            | arm64    | 0.12.0 | latest | 3.0.0       | 3.5.0 | 3.6.3      | 1.5.3  | 0.9.0 |

> Note, the arm64 version is built for ARM64 platforms like Mac M1

Download the appropriate tag, e.g.:

- `docker pull deltaio/delta-docker:latest` for the standard Linux docker
- `docker pull deltaio/delta-docker:latest_arm64` for running this optimally on your Mac M1

#### Image Entry Point

Your entry point for the Docker Hub image is:

```bash
# Running locally on Mac M1
docker run --name delta_quickstart --rm -it --entrypoint bash deltaio/delta-docker:latest_arm64
```

```bash
# Running on Linux VM
docker run --name delta_quickstart --rm -it --entrypoint bash deltaio/delta-docker:latest
```

Once the image has been built or you have downloaded the correct image, you can then move on to running the quickstart in a notebook or shell.

## Choose the Delta Package version

In the following instructions, the variable `${DELTA_PACKAGE_VERSION}` refers to the Delta Lake Package version.

The current version is `delta-spark_2.12:3.0.0` which corresponds to Apache Spark 3.5.x release line.

## Choose an Interface

- [delta-rs Python](#delta-rs-python)
- [JupyterLab Notebook](#jupyterlab-notebook)
- [PySpark Shell](#pyspark-shell)
- [Scala Shell](#scala-shell)
- [Delta Rust API](#delta-rust-api)
- [ROAPI](#optional-roapi)

### delta-rs Python

1. Open a bash shell (if on windows use git bash, WSL, or any shell configured for bash commands)

1. Run a container from the image with a bash entrypoint ([build](#build-entry-point) | [DockerHub](#image-entry-point))

1. Launch a _python_ interactive shell session with `python3`

   ```bash
   python3
   ```

   > Note: The Delta Rust Python bindings are already installed in this docker. To do this manually in your own environment, run the command: `pip3 install deltalake==0.12.0`

1. Run some basic commands in the shell to write to and read from Delta Lake with Pandas

   ```python
   import pandas as pd
   from deltalake.writer import write_deltalake
   from deltalake import DeltaTable

   # Create a Pandas DataFrame
   df = pd.DataFrame({"data": range(5)})

   # Write to the Delta Lake table
   write_deltalake("/tmp/deltars_table", df)

   # Append new data
   df = pd.DataFrame({"data": range(6, 11)})
   write_deltalake("/tmp/deltars_table", df, mode="append")

   # Read the Delta Lake table
   dt = DeltaTable("/tmp/deltars_table")

   # Show the Delta Lake table
   dt.to_pandas()
   ```

   ```python
   ## Output
      data
   0     0
   1     1
   2     2
   ...
   8     9
   9    10
   ```

1. Review the files

   ```python
   # List files for the Delta Lake table
   dt.files()
   ```

   ```python
   ## Output
   ['0-6944fddf-60e3-4eab-811d-1398e9f64073-0.parquet', '1-66c7ee6e-6aab-4c74-866d-a82790102652-0.parquet']
   ```

1. Review history

   ```python
   # Review history
   dt.history()
   ```

   ```python
   ## Output
   [{'timestamp': 1698002214493, 'operation': 'WRITE', 'operationParameters': {'mode': 'Append', 'partitionBy': '[]'}, 'clientVersion': 'delta-rs.0.17.0', 'version': 1}, {'timestamp': 1698002207527, 'operation': 'CREATE TABLE', 'operationParameters': {'mode': 'ErrorIfExists', 'protocol': '{"minReaderVersion":1,"minWriterVersion":1}', 'location': 'file:///tmp/deltars_table', 'metadata': '{"configuration":{},"created_time":1698002207525,"description":null,"format":{"options":{},"provider":"parquet"},"id":"bf749aab-22b6-484b-bd73-dc1680ee4384","name":null,"partition_columns":[],"schema":{"fields":[{"metadata":{},"name":"data","nullable":true,"type":"long"}],"type":"struct"}}'}, 'clientVersion': 'delta-rs.0.17.0', 'version': 0}]
   ```

1. Time Travel (load older version of table)

   ```python
   # Load initial version of table
   dt.load_version(0)

   # Show table
   dt.to_pandas()
   ```

   ```python
   ## Output
      data
   0     0
   1     1
   2     2
   3     3
   4     4
   ```

1. Follow the delta-rs Python documentation [here](https://delta-io.github.io/delta-rs/python/usage.html#)

1. To verify that you have a Delta Lake table, you can list the contents within the folder of your Delta Lake table. For example, in the previous code, you saved the table in `/tmp/deltars-table`. Once you close your `python3` process, run a list command in your Docker shell and you should get something similar to below.

   ```bash
   $ ls -lsgA /tmp/deltars_table
   ```

   ```bash
   total 12
   4 -rw-r--r-- 1 NBuser 1689 Oct 22 19:16 0-6944fddf-60e3-4eab-811d-1398e9f64073-0.parquet
   4 -rw-r--r-- 1 NBuser 1691 Oct 22 19:16 1-66c7ee6e-6aab-4c74-866d-a82790102652-0.parquet
   4 drwxr-xr-x 2 NBuser 4096 Oct 22 19:16 _delta_log
   ```

1. [Optional] Skip ahead to try out the [Delta Rust API](#delta-rust-api) and [ROAPI](#optional-roapi)

### JupyterLab Notebook

1. Open a bash shell (if on windows use git bash, WSL, or any shell configured for bash commands)

2. Run a container from the image with a JuypterLab entrypoint

   ```bash
   # Build entry point
   docker run --name delta_quickstart --rm -it -p 8888-8889:8888-8889 delta_quickstart
   ```

   ```bash
   # Image entry point (M1)
   docker run --name delta_quickstart --rm -it -p 8888-8889:8888-8889 -entrypoint bash deltaio/delta-docker:latest_arm64
   ```

3. Running the above command gives a JupyterLab notebook URL, copy that URL and launch a browser to follow along the notebook and run each cell.

   > **Note that you may also launch the pyspark or scala shells after launching a terminal in JupyterLab**

### PySpark Shell

1. Open a bash shell (if on windows use git bash, WSL, or any shell configured for bash commands)

2. Run a container from the image with a bash entrypoint ([build](#build-entry-point) | [DockerHub](#image-entry-point))

3. Launch a pyspark interactive shell session

   ```bash

   $SPARK_HOME/bin/pyspark --packages io.delta:${DELTA_PACKAGE_VERSION} \
   --conf spark.driver.extraJavaOptions="-Divy.cache.dir=/tmp -Divy.home=/tmp" \
   --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" \
   --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
   ```

   > Note: `DELTA_PACKAGE_VERSION` is set in `./startup.sh`

4. Run some basic commands in the shell

   ```python
   # Create a Spark DataFrame
   data = spark.range(0, 5)

   # Write to a Delta Lake table
   (data
      .write
      .format("delta")
      .save("/tmp/delta-table")
   )

   # Read from the Delta Lake table
   df = (spark
           .read
           .format("delta")
           .load("/tmp/delta-table")
           .orderBy("id")
         )

   # Show the Delta Lake table
   df.show()
   ```

   ```python
   ## Output
   +---+
   | id|
   +---+
   |  0|
   |  1|
   |  2|
   |  3|
   |  4|
   +---+
   ```

5. Continue with the quickstart [here](https://docs.delta.io/latest/quick-start.html#create-a-table&language-python)

6. To verify that you have a Delta Lake table, you can list the contents within the folder of your Delta Lake table. For example, in the previous code, you saved the table in `/tmp/delta-table`. Once you close your `pyspark` process, run a list command in your Docker shell and you should get something similar to below.

   ```bash
   $ ls -lsgA /tmp/delta-table
   ```

   ```bash
   total 52
   4 drwxr-xr-x 2 NBuser 4096 Oct 22 19:23 _delta_log
   4 -rw-r--r-- 1 NBuser  296 Oct 22 19:23 part-00000-dc0fd6b3-9c0f-442f-a6db-708301b27bd2-c000.snappy.parquet
   4 -rw-r--r-- 1 NBuser   12 Oct 22 19:23 .part-00000-dc0fd6b3-9c0f-442f-a6db-708301b27bd2-c000.snappy.parquet.crc
   4 -rw-r--r-- 1 NBuser  478 Oct 22 19:23 part-00001-d379441e-1ee4-4e78-8616-1d9635df1c7b-c000.snappy.parquet
   4 -rw-r--r-- 1 NBuser   12 Oct 22 19:23 .part-00001-d379441e-1ee4-4e78-8616-1d9635df1c7b-c000.snappy.parquet.crc
   4 -rw-r--r-- 1 NBuser  478 Oct 22 19:23 part-00003-c08dcac4-5ea9-4329-b85d-9110493e8757-c000.snappy.parquet
   4 -rw-r--r-- 1 NBuser   12 Oct 22 19:23 .part-00003-c08dcac4-5ea9-4329-b85d-9110493e8757-c000.snappy.parquet.crc
   4 -rw-r--r-- 1 NBuser  478 Oct 22 19:23 part-00005-5db8dd16-2ab1-4d76-9b4d-457c5641b1c8-c000.snappy.parquet
   4 -rw-r--r-- 1 NBuser   12 Oct 22 19:23 .part-00005-5db8dd16-2ab1-4d76-9b4d-457c5641b1c8-c000.snappy.parquet.crc
   4 -rw-r--r-- 1 NBuser  478 Oct 22 19:23 part-00007-cad760e0-3c26-4d22-bed6-7d75a9459a0f-c000.snappy.parquet
   4 -rw-r--r-- 1 NBuser   12 Oct 22 19:23 .part-00007-cad760e0-3c26-4d22-bed6-7d75a9459a0f-c000.snappy.parquet.crc
   4 -rw-r--r-- 1 NBuser  478 Oct 22 19:23 part-00009-b58e8445-07b7-4e2a-9abf-6fea8d0c3e3f-c000.snappy.parquet
   4 -rw-r--r-- 1 NBuser   12 Oct 22 19:23 .part-00009-b58e8445-07b7-4e2a-9abf-6fea8d0c3e3f-c000.snappy.parquet.crc
   ```

### Scala Shell

1. Open a bash shell (if on windows use git bash, WSL, or any shell configured for bash commands)

2. Run a container from the image with a bash entrypoint ([build](#build-entry-point) | [DockerHub](#image-entry-point))

3. Launch a scala interactive shell session

   ```bash
   $SPARK_HOME/bin/spark-shell --packages io.delta:${DELTA_PACKAGE_VERSION} \
   --conf spark.driver.extraJavaOptions="-Divy.cache.dir=/tmp -Divy.home=/tmp" \
   --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" \
   --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
   ```

4. Run some basic commands in the shell

   > note: if you've already written to the Delta table in the python shell example, use `.mode("overwrite")` to overwrite the current delta table. You can always time-travel to rewind.

   ```scala
   // Create a Spark DataFrame
   val data = spark.range(0, 5)

   // Write to a Delta Lake table

   (data
      .write
      .format("delta")
      .save("/tmp/delta-table")
   )

   // Read from the Delta Lake table
   val df = (spark
               .read
               .format("delta")
               .load("/tmp/delta-table")
               .orderBy("id")
            )

   // Show the Delta Lake table
   df.show()
   ```

   ```scala
   ## Output
   +---+
   | id|
   +---+
   |  0|
   |  1|
   |  2|
   |  3|
   |  4|
   +---+
   ```

5. Follow the quickstart [here](https://docs.delta.io/latest/quick-start.html#create-a-table&language-scala)

6. To verify that you have a Delta Lake table, you can list the contents within the folder of your Delta Lake table. For example, in the previous code, you saved the table in `/tmp/delta-table`. Once you close your Scala Spark process [`spark-shell`], run a list command in your Docker shell and you should get something similar to below.

   ```bash
   $ ls -lsgA /tmp/delta-table
   ```

   ```bash
   total 52
   4 drwxr-xr-x 2 NBuser 4096 Oct 22 19:28 _delta_log
   4 -rw-r--r-- 1 NBuser  296 Oct 22 19:28 part-00000-f1f417f7-df64-4c7c-96f2-6a452ae2b49e-c000.snappy.parquet
   4 -rw-r--r-- 1 NBuser   12 Oct 22 19:28 .part-00000-f1f417f7-df64-4c7c-96f2-6a452ae2b49e-c000.snappy.parquet.crc
   4 -rw-r--r-- 1 NBuser  478 Oct 22 19:28 part-00001-b28acb6f-f08a-460f-a24e-4d9c1affee86-c000.snappy.parquet
   4 -rw-r--r-- 1 NBuser   12 Oct 22 19:28 .part-00001-b28acb6f-f08a-460f-a24e-4d9c1affee86-c000.snappy.parquet.crc
   4 -rw-r--r-- 1 NBuser  478 Oct 22 19:28 part-00003-29079c58-d1ad-4604-9c04-0f00bf09546d-c000.snappy.parquet
   4 -rw-r--r-- 1 NBuser   12 Oct 22 19:28 .part-00003-29079c58-d1ad-4604-9c04-0f00bf09546d-c000.snappy.parquet.crc
   4 -rw-r--r-- 1 NBuser  478 Oct 22 19:28 part-00005-04424aa7-48e1-4212-bd57-52552c713154-c000.snappy.parquet
   4 -rw-r--r-- 1 NBuser   12 Oct 22 19:28 .part-00005-04424aa7-48e1-4212-bd57-52552c713154-c000.snappy.parquet.crc
   4 -rw-r--r-- 1 NBuser  478 Oct 22 19:28 part-00007-e7a54a4f-bee4-4371-a35d-d284e28eb9f8-c000.snappy.parquet
   4 -rw-r--r-- 1 NBuser   12 Oct 22 19:28 .part-00007-e7a54a4f-bee4-4371-a35d-d284e28eb9f8-c000.snappy.parquet.crc
   4 -rw-r--r-- 1 NBuser  478 Oct 22 19:28 part-00009-086e6cd9-e8c6-4f16-9658-b15baf22905d-c000.snappy.parquet
   4 -rw-r--r-- 1 NBuser   12 Oct 22 19:28 .part-00009-086e6cd9-e8c6-4f16-9658-b15baf22905d-c000.snappy.parquet.crc
   ```

</details>

### Delta Rust API

> Note: Use a docker volume in case of running into limits "no room left on device"
> `docker volume create rustbuild` > `docker run --name delta_quickstart -v rustbuild:/tmp --rm -it --entrypoint bash deltaio/delta-docker:3.0.0`

1. Open a bash shell (if on windows use git bash, WSL, or any shell configured for bash commands)

2. Run a container from the image with a bash entrypoint ([build](#build-entry-point) | [DockerHub](#image-entry-point))

3. Execute `examples/read_delta_table.rs` to review the Delta Lake table metadata and files of the `covid19_nyt` Delta Lake table.

   ```bash
   cd rs
   cargo run --example read_delta_table
   ```

   > You can also use a different location to build and run the examples

   ```bash
   cd rs
   CARGO_TARGET_DIR=/tmp cargo run --example read_delta_table
   ```

   > If using [Delta Lake DockerHub](https://go.delta.io/dockerhub), sometimes the Rust environment hasn't been configured. To resolve this, run the command `source "$HOME/.cargo/env"`

   ```bash
   === Delta table metadata ===
   DeltaTable(/opt/spark/work-dir/rs/data/COVID-19_NYT)
      version: 0
      metadata: GUID=7245fd1d-8a6d-4988-af72-92a95b646511, name=None, description=None, partitionColumns=[], createdTime=Some(1619121484605), configuration={}
      min_version: read=1, write=2
      files count: 8


   === Delta table files ===
   [Path { raw: "part-00000-a496f40c-e091-413a-85f9-b1b69d4b3b4e-c000.snappy.parquet" }, Path { raw: "part-00001-9d9d980b-c500-4f0b-bb96-771a515fbccc-c000.snappy.parquet" }, Path { raw: "part-00002-8826af84-73bd-49a6-a4b9-e39ffed9c15a-c000.snappy.parquet" }, Path { raw: "part-00003-539aff30-2349-4b0d-9726-c18630c6ad90-c000.snappy.parquet" }, Path { raw: "part-00004-1bb9c3e3-c5b0-4d60-8420-23261f58a5eb-c000.snappy.parquet" }, Path { raw: "part-00005-4d47f8ff-94db-4d32-806c-781a1cf123d2-c000.snappy.parquet" }, Path { raw: "part-00006-d0ec7722-b30c-4e1c-92cd-b4fe8d3bb954-c000.snappy.parquet" }, Path { raw: "part-00007-4582392f-9fc2-41b0-ba97-a74b3afc8239-c000.snappy.parquet" }]
   ```

4. Execute `examples/read_delta_datafusion.rs` to query the `covid19_nyt` Delta Lake table using `datafusion`

   ```bash
   cargo run --example read_delta_datafusion
   ```

   ```bash
   === Datafusion query ===
   [RecordBatch { schema: Schema { fields: [Field { name: "cases", data_type: Int32, nullable: true, dict_id: 0, dict_is_ordered: false, metadata: None }, Field { name: "county", data_type: Utf8, nullable: true, dict_id: 0, dict_is_ordered: false, metadata: None }, Field { name: "date", data_type: Utf8, nullable: true, dict_id: 0, dict_is_ordered: false, metadata: None }], metadata: {} }, columns: [PrimitiveArray<Int32>
   [
      1,
      1,
      1,
      1,
      1,
   ], StringArray
   [
      "Snohomish",
      "Snohomish",
      "Snohomish",
      "Cook",
      "Snohomish",
   ], StringArray
   [
      "2020-01-21",
      "2020-01-22",
      "2020-01-23",
      "2020-01-24",
      "2020-01-24",
   ]], row_count: 5 }]
   ```

</p>
</details>

### [Optional] ROAPI

You can query your Delta Lake table with [Apache Arrow](https://github.com/apache/arrow) and [Datafusion](https://github.com/apache/arrow-datafusion) using [ROAPI](https://roapi.github.io/docs/config/dataset-formats/delta.html) which are pre-installed in this docker.

> Note: If you need to do this in your own environment, run the command `pip3 install roapi==0.9.0`

1. Open a bash shell (if on windows use git bash, WSL, or any shell configured for bash commands)

2. Run a container from the image with a bash entrypoint ([build](#build-entry-point) | [DockerHub](#image-entry-point))

3. Start the `roapi` API using the following command. Notes:

   - the API calls are pushed to the `nohup.out` file.
   - if you haven't created the `deltars_table` in your container create it via the [delta-rs Python](#delta-rs-python) option above. Alternatively you may omit the following from the command:
     `--table 'deltars_table=/tmp/deltars_table/,format=delta'` as well as any steps that call the `deltars_table`

   ```bash
   nohup roapi --addr-http 0.0.0.0:8080 --table 'deltars_table=/tmp/deltars_table/,format=delta' --table 'covid19_nyt=/opt/spark/work-dir/rs/data/COVID-19_NYT,format=delta' &
   ```

4. Check the schema of the two Delta Lake tables

   ```bash
   curl localhost:8080/api/schema
   ```

   ```bash
   {
      "covid19_nyt":{"fields":[
         {"name":"date","data_type":"Utf8","nullable":true,"dict_id":0,"dict_is_ordered":false},
         {"name":"county","data_type":"Utf8","nullable":true,"dict_id":0,"dict_is_ordered":false},
         {"name":"state","data_type":"Utf8","nullable":true,"dict_id":0,"dict_is_ordered":false},
         {"name":"fips","data_type":"Int32","nullable":true,"dict_id":0,"dict_is_ordered":false},
         {"name":"cases","data_type":"Int32","nullable":true,"dict_id":0,"dict_is_ordered":false},
         {"name":"deaths","data_type":"Int32","nullable":true,"dict_id":0,"dict_is_ordered":false}
      ]},
      "deltars_table":{"fields":[
         {"name":"0","data_type":"Int64","nullable":true,"dict_id":0,"dict_is_ordered":false}
      ]}
   }
   ```

5. Query the `deltars_table`

   ```bash
   curl -X POST -d "SELECT * FROM deltars_table"  localhost:8080/api/sql
   ```

   ```bash
   # output
   [{"0":0},{"0":1},{"0":2},{"0":3},{"0":4},{"0":6},{"0":7},{"0":8},{"0":9},{"0":10}]
   ```

6. Query the `covid19_nyt` table

   ```bash
   curl -X POST -d "SELECT cases, county, date FROM covid19_nyt ORDER BY cases DESC LIMIT 5" localhost:8080/api/sql
   ```

   ```bash
   [
      {"cases":1208672,"county":"Los Angeles","date":"2021-03-11"},
      {"cases":1207361,"county":"Los Angeles","date":"2021-03-10"},
      {"cases":1205924,"county":"Los Angeles","date":"2021-03-09"},
      {"cases":1204665,"county":"Los Angeles","date":"2021-03-08"},
      {"cases":1203799,"county":"Los Angeles","date":"2021-03-07"}
   ]
   ```
