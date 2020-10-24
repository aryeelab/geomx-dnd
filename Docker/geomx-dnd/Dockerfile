FROM marketplace.gcr.io/google/ubuntu1804
ARG VERSION=__specify_in_build_arg__

RUN apt-get update && apt-get install -y \
    curl \
    zip 

COPY monitor_v2.sh /usr/local/bin/

RUN echo $VERSION > /VERSION


