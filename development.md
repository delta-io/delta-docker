## Build Locally
If you want to test out the local build, use the following command:
```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t deltaio_delta-docker:latest \
  -f Dockerfile \
  . 
```
> Note: The first build will take longer as it will download the base image, and setup the rust environment in the image.

Build without the cache only if you want to rebuild the full image from scratch.
```bash
docker buildx build \
  --no-cache \
  --platform linux/amd64,linux/arm64 \
  -t deltaio_delta-docker:latest \
  -f Dockerfile \
  . 
```
## Run Local Build

Run the environment and pop into the bash shell.
```bash
docker run \
  --name delta_quickstart \
  --rm \
  -it \
  --entrypoint bash \
  deltaio_delta-docker:latest
```

Run the environment and pop into the jupyter lab.
```bash
docker run \
  --name delta_quickstart \
  --rm \
  -it \
  -p 8888-8889:8888-8889 \
  deltaio_delta-docker:latest
```