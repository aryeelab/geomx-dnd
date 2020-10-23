### Setup


In order to push/pull images from the Google container registry you must first authenticate with Google:

```bash
gcloud auth login
```

You then need to run a one-time setup to configure docker to use Google authentication:

```bash
gcloud auth configure-docker
```


### Running a test

```bash
cd test
cromwell run -i oneseq_processing.inputs.BE3_small_test.json oneseq_processing.wdl 
```


### Updating the Docker container

After modifying the Dockerfile (`Docker/geomx-ngs/Dockerfile`) a new image can be built locally:

```bash
cd Docker/geomx-ngs
docker build -t gcr.io/aryeelab/geomx-ngs .
```

If it works as expected you can commit the change to git repo. Pushing to github 
will trigger a new container build using [Google Cloud Build](https://cloud.google.com/cloud-build). 
The new image is automatically stored in Google Container Registry.

```bash

```
