# Delta Lake Quickstart Docker
This folder contains instructions and materials to get new users started with Delta Lake and work through the 
quickstart materials using a self-contained Docker image.

> Note: The basic prerequisite for following along using the Delta Lake Docker image is having Docker installed on your 
> machine. Please follow the steps from the Docker website to install Docker locally. Based on your local machine 
> operating system, please choose the appropriate option listed on 
> the [Get Docker](https://docs.docker.com/get-docker/) page.

Follow the steps below to build an Apache Spark<sup>TM</sup> image with Delta Lake installed, run a container, and follow the quickstart in an interactive notebook or shell with any of the options like Python, PySpark, Scala Spark, and even Rust.

1. [Working with Docker](#working-with-docker)
   1. [Build the image](#build-the-image)
   2. [Docker Hub](#docker-hub)
2. [Publishing a Release](#publishing-a-release)
3. [Testing the Image](#testing-the-image)
4. [Choose an interface](#choose-an-interface)

> Note: The Python version available in this Docker image is 3.10.12 and is available as `python3`.

## Working with Docker

### Build the Image

1. Clone this repo
2. Navigate to the cloned folder
3. Open a bash shell (if on Windows, use git bash, WSL, or any shell configured for bash commands)

```bash
docker build -t delta_quickstart -f Dockerfile .
```

#### Build Entry Point

Your entry point for this locally built Docker file is

```bash
docker run \
  --name delta_quickstart \
  --rm -it \
  --entrypoint bash delta_quickstart
```

### Docker Hub

You can also download the image from DockerHub at [Delta Lake DockerHub](https://go.delta.io/dockerhub)

| Tag               | Platform    | Python | Rust   | Delta-Spark | Spark | JupyterLab | Pandas | Polars | ROAPI  |
|-------------------|-------------|--------|--------|-------------|-------|------------|--------|--------|--------|
| 4.0.0             | arm64/amd64 | 1.1.14 | 1.1.14 | 4.0.0       | 4.0.0 | 4.4.6      | x      | 1.33.1 | 0.12.6 |
| 4.0.1             | arm64/amd64 | 1.4.0  | 1.4.0  | 4.0.1       | 4.0.1 | 4.4.6      | x      | 1.33.1 | 0.12.6 |
| 4.1.0             | arm64/amd64 | 1.4.0  | 1.4.0  | 4.1.0       | 4.1.0 | 4.4.6      | x      | 1.33.1 | 0.12.6 |
| 4.2.0             | arm64/amd64 | 1.6.2  | 1.6.2  | 4.2.0       | 4.2.0 | 4.6.2      | x      | 1.43.2 | 0.12.7 |
| 4.3.0             | arm64/amd64 | 1.6.2  | 1.6.2  | 4.3.0       | 4.1.1 | 4.6.2      | x      | 1.43.2 | 0.12.7 |
| latest            | arm64/amd64 | 1.6.2  | 1.6.2  | 4.3.0       | 4.1.1 | 4.6.2      | x      | 1.43.2 | 0.12.7 |


## Running the Docker environment
>  We've moved to using multiplatform Docker images. You can now download the image from DockerHub at [Delta Lake DockerHub](https://go.delta.io/dockerhub).

```bash
docker pull deltaio/delta-docker:latest
``` 

#### Image Entry Point

Your entry point for the Docker Hub image is:

```bash
# Running on your laptop
docker run \
  --name delta_quickstart \
  --rm \
  -it \
  --entrypoint bash \
  deltaio/delta-docker:latest
```

Once the image has been built or you have downloaded the correct image, you can then move on to running the quickstart in a notebook or shell.

## Choose the Delta Package version

In the following instructions, the variable `${DELTA_PACKAGE_VERSION}` refers to the Delta Lake Package version.

The current version is `delta-spark_2.13:4.3.0` which corresponds to Apache Spark 4.x release line.

## Choose an Interface

- [delta-rs Python](#delta-rs-python)
- [JupyterLab Notebook](#jupyterlab-notebook)
- [PySpark Shell](#pyspark-shell)
- [Scala Shell](#scala-shell)
- [Delta Rust API](#delta-rust-api)
- [ROAPI](#optional-roapi)
---
### delta-rs Python

1. Open a bash shell (if on Windows, use git bash, WSL, or any shell configured for bash commands)

2. Run a container from the image with a bash entrypoint ([build](#build-entry-point) | [DockerHub](#image-entry-point))

3. Launch a _python_ interactive shell session with `python3`

    ```bash
    python3
    ```

    > Note: The Delta Rust Python bindings are already installed in this Docker. To do this manually in your own environment, run the command: `pip3 install deltalake==1.1.4`

4. Run some basic commands in the shell to write to and read from Delta Lake with Polars

    ```python
    import polars as pl
    table_path = "/tmp/owners_table"
    
    # Create a Polars DataFrame
    df = pl.DataFrame({'name': ['scott', 'milo'], 'age': [41, 10]})
    # Write to the Delta Lake table
    df.write_delta(table_path)
    
    # View the Table
    print(pl.read_delta(table_path))
    
    #shape: (2, 2)
    #┌───────┬─────┐
    #│ name  ┆ age │
    #│ ---   ┆ --- │
    #│ str   ┆ i64 │
    #╞═══════╪═════╡
    #│ scott ┆ 41  │
    #│ milo  ┆ 10  │
    #└───────┴─────┘
    
    # Append new data
    df2 = pl.DataFrame({'name': ['clover', 'willow'], 'age': [9, 15]})
    df2.write_delta(table_path, mode="append")
    
    # Read the Updated Delta Lake table
    print(pl.read_delta(table_path))
    # shape: (4, 2)
    #┌────────┬─────┐
    #│ name   ┆ age │
    #│ ---    ┆ --- │
    #│ str    ┆ i64 │
    #╞════════╪═════╡
    #│ clover ┆ 9   │
    #│ willow ┆ 15  │
    #│ scott  ┆ 41  │
    #│ milo   ┆ 10  │
    #└────────┴─────┘
    ```

5. Create a `DeltaTable` instance
   ```python
   from deltalake import DeltaTable
   table_path = "/tmp/owners_table"
   dt = DeltaTable(table_path)
   ```

6. Review the files in the table

    ```python
    # List files for the Delta Lake table
    dt.file_uris()
    ```

    ```python
    ## Output
    [
     '/tmp/owners_table/part-00001-482b379f-4b9c-4e03-aeec-1f0d1e3afbc3-c000.snappy.parquet',
     '/tmp/owners_table/part-00001-8d41dd54-25d1-4a62-b371-72c61cdca0ff-c000.snappy.parquet'
    ]
    ```

7. Review the Delta table history

   ```python
    # Review history
    dt.history()
    ```

    ```python
    ## Output
    [{'timestamp': 1758219638102, 'operation': 'WRITE', 'operationParameters': {'mode': 'Append'}, 'engineInfo': 'delta-rs:py-1.1.4', 'operationMetrics': {'execution_time_ms': 6, 'num_added_files': 1, 'num_added_rows': 2, 'num_partitions': 0, 'num_removed_files': 0}, 'clientVersion': 'delta-rs.py-1.1.4', 'version': 1}, {'timestamp': 1758219572045, 'operation': 'WRITE', 'operationParameters': {'mode': 'ErrorIfExists'}, 'engineInfo': 'delta-rs:py-1.1.4', 'clientVersion': 'delta-rs.py-1.1.4', 'operationMetrics': {'execution_time_ms': 13, 'num_added_files': 1, 'num_added_rows': 2, 'num_partitions': 0, 'num_removed_files': 0}, 'version': 0}]
    ```

8. Time Travel (load an older version of the table)

    ```python
    # Load initial version of table
    older_data = pl.read_delta(table_path, version=0)
    # Show table
    print(older_data)
    ```

    ```python
    ## Output
    shape: (2, 2)
   ┌───────┬─────┐
   │ name  ┆ age │
   │ ---   ┆ --- │
   │ str   ┆ i64 │
   ╞═══════╪═════╡
   │ scott ┆ 41  │
   │ milo  ┆ 10  │
   └───────┴─────┘
    ```

    > Tip: Follow the delta-rs Python documentation [here](https://delta-io.github.io/delta-rs/python/usage.html#)

9. To verify that you have a Delta Lake table, you can list the contents within the folder of your Delta Lake table. For example, in the previous code, you saved the table in `/tmp/deltars-table`. Once you close your `python3` process, run a list command in your Docker shell, and you should get something similar to below.

    ```bash
    $ ls -lsgA /tmp/owners_table/
    ```

    ```bash
    total 12
    4 drwxr-xr-x 2 NBuser 4096 Sep 18 18:20 _delta_log
    4 -rw-r--r-- 1 NBuser  834 Sep 18 18:20 part-00001-482b379f-4b9c-4e03-aeec-1f0d1e3afbc3-c000.snappy.parquet
    4 -rw-r--r-- 1 NBuser  822 Sep 18 18:19 part-00001-8d41dd54-25d1-4a62-b371-72c61cdca0ff-c000.snappy.parquet
    ```

10. [Optional] Skip ahead to try out the [Delta Rust API](#delta-rust-api) and [ROAPI](#optional-roapi)
---

### JupyterLab Notebook

1. Open a bash shell (if on Windows, use git bash, WSL, or any shell configured for bash commands)
2. Run a container from the image with a JupyterLab entrypoint

    ```bash
    # Build entry point
    docker run \
      --name delta_quickstart \
      --rm \
      -it \
      -p 8888-8889:8888-8889 \
      deltaio/delta-docker:latest
    ```

3. Running the above command gives a JupyterLab notebook URL. Copy that URL and launch a browser to follow along with the notebook and run each cell.

    > **Note that you may also launch the pyspark or scala shells after launching a terminal in JupyterLab**
---
### PySpark Shell

1. Open a bash shell (if on Windows, use git bash, WSL, or any shell configured for bash commands)

2. Run a container from the image with a bash entrypoint ([build](#build-entry-point) | [DockerHub](#image-entry-point))

3. Launch a PySpark interactive shell session

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
<details title="Output">

   ```text
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

</details>
---

### Scala Shell

1. Open a bash shell (if on Windows, use git bash, WSL, or any shell configured for bash commands)

2. Run a container from the image with a bash entrypoint ([build](#build-entry-point) | [DockerHub](#image-entry-point))

3. Launch a Scala interactive shell session

   ```bash
   $SPARK_HOME/bin/spark-shell --packages io.delta:${DELTA_PACKAGE_VERSION} \
   --conf spark.driver.extraJavaOptions="-Divy.cache.dir=/tmp -Divy.home=/tmp" \
   --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" \
   --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
   ```

4. Run some basic commands in the shell

   > Note: if you've already written to the Delta table in the Python shell example, use `.mode("overwrite")` to overwrite the current Delta table. You can always time-travel to rewind.

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

6. To verify that you have a Delta Lake table, you can list the contents within the folder of your Delta Lake table. For example, in the previous code, you saved the table in `/tmp/delta-table`. Once you close your Scala Spark process [`spark-shell`], run a list command in your Docker shell, and you should get something similar to below.

```bash
$ ls -lsgA /tmp/delta-table
```
<details>
    
```text
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

---

### Delta Rust API

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

> Note: Use a Docker volume in case of running into limits, "no room left on device"
<details>
<summary>How to Resolve the <b>no room left on device</b> issue</summary>

---

To fix the issue, you'll need to mount a volume to the container.

You'll need to start by creating the volume.
```bash
docker volume create rustbuild
```

Then you can mount the volume to the container at runtime.

```bash
docker run \
  --name delta_quickstart \
  -v rustbuild:/tmp \
  --rm -it \
  --entrypoint bash deltaio/delta-docker:4.0.0
```

At this point, you should be able to run the examples without any issues.

---
</details>

---

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
   
# Triggering Multiplatform Builds
We no longer need to create and maintain separate Dockerfiles for each platform. We can now use the `buildx` command to build multi-platform images.

## Build Locally for Tests
```bash
docker buildx build \
  --platform linux/arm64 \
  -t deltaio_delta-docker:latest \
  -f Dockerfile \
  --load \
  . 
```

## Build and Push to DockerHub
```bash
# bash
# Replace placeholders with your values
REGISTRY_USERNAME=deltaio
IMAGE_NAME=delta-docker
IMAGE_TAG=4.0.1   # e.g., 4.0.1 or latest

docker login

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ${REGISTRY_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} \
  -f Dockerfile \
  --push \
  .
```

## Publishing a Release

The repository includes a GitHub Actions workflow (`.github/workflows/release.yml`) that automatically builds and publishes the Docker image to [Docker Hub](https://go.delta.io/dockerhub) when a GitHub Release is published.

### Workflow steps

| Job | What it does |
|---|---|
| **test** | Builds a single-platform image on the Actions runner and runs the full `tests/test_docker.sh` integration suite. |
| **push** | Only runs when `test` passes. Builds a multi-platform image (`linux/amd64` + `linux/arm64`) and pushes to `deltaio/delta-docker` on Docker Hub. |

### Tagging convention

The image tag is derived from the GitHub Release tag directly via `github.ref_name`:

| GitHub Release tag | Docker Hub tags produced |
|---|---|
| `4.1.0` | `deltaio/delta-docker:4.1.0`, `deltaio/delta-docker:latest` |

### Required secrets / variables

Configure these in **Settings → Secrets and variables → Actions** on the repository:

| Name | Type | Description |
|---|---|---|
| `DOCKERHUB_USERNAME` | Variable (`vars`) | Docker Hub username |
| `DOCKERHUB_TOKEN` | Secret (`secrets`) | Docker Hub access token |

---

## Testing the Image

After building the image locally you can run the integration test suite to verify that all packages installed correctly and that core Delta Lake operations work end-to-end.

### Quick start

```bash
# Build then test in one step
make build-and-test

# Or run tests against an already-built image
make test

# Override the image name if needed
make test IMAGE_NAME=my_custom_image
```

### Running the test script directly

```bash
./tests/test_docker.sh [IMAGE_NAME]
```

`IMAGE_NAME` defaults to `delta_quickstart` when omitted.

### What is tested

| Category | What is verified |
|---|---|
| System tools | `vim`, `curl`, `tree` are installed |
| Python runtime | `python3` and `pip` are on `PATH` |
| Package imports | `delta`, `deltalake`, `polars`, `pyarrow`, `pyspark`, `jupyterlab` all import cleanly |
| Package versions | Installed versions match the pinned `ARG` values in the `Dockerfile` |
| Apache Spark | `spark-submit` and `pyspark` are on `PATH` |
| Rust toolchain | `rustc` and `cargo` are available via `~/.cargo/env` |
| Functional (Polars) | Write and append a Delta table using `polars.write_delta` and read it back |
| Functional (deltalake) | `DeltaTable` returns a non-empty file URI list and history |

A non-zero exit code is returned (and all failures are reported) if any test fails, making this suitable for use in CI.

---
