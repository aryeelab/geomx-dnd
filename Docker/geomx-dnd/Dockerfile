FROM marketplace.gcr.io/google/ubuntu1804
ARG VERSION=__specify_in_build_arg__

RUN apt-get update && apt-get install -y \
    wget \
    zip \
    busybox-static

RUN echo $VERSION > /VERSION

