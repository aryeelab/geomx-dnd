### Setup


In order to push/pull images from the Google container registry you must first authenticate with Google:

```bash
gcloud auth login
```

You then need to run a one-time setup to configure docker to use Google authentication:

```bash
gcloud auth configure-docker
```


### Process a sample dataset
These steps download and process a sample dataset from Nanostring. The sample
inputs are specified in `tests/3sampleAOIs_20200504.json`.


```bash
cd tests

# Get the FASTQs (1Gb)
wget http://storage.googleapis.com/aryeelab/geomx/3sampleAOIs_20200504_DND/FASTQ.zip

# Get the config ini file:
wget http://storage.googleapis.com/aryeelab/geomx/3sampleAOIs_20200504_DND/3sampleAOIs_20200504_DND_config.ini

# Run the workflow
cromwell run -i 3sampleAOIs_20200504.json ../preprocess_geomx_dnd.wdl 
```


### Updating the Docker container

After modifying the Dockerfile (`Docker/geomx-dnd/Dockerfile`) a new image can be built locally:

```bash
cd Docker/geomx-dnd
docker build -t gcr.io/aryeelab/geomx-dnd .
```

If it works as expected you can commit the change to git repo. Pushing to github 
will trigger a new container build using [Google Cloud Build](https://cloud.google.com/cloud-build). 
The new image is automatically stored in Google Container Registry.  

```bash

```
