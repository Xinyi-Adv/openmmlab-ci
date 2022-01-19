ARG OS_VERSION="18.04"

FROM ubuntu:${OS_VERSION}

ARG PYTORCH="1.6.0"
ARG TORCHVISION="0.7.0"
ARG PYTHON="3.7"
ARG MMCV_VERSION="1.4.0"

RUN apt-get update && apt-get install -y ffmpeg libturbojpeg ninja-build libprotobuf-dev protobuf-compiler cmake git curl wget
RUN if [ "$PYTHON" != "3.9" ] ; then apt-get install -y python3-pip python${PYTHON}-dev ; else apt-get install -y python${PYTHON} python${PYTHON}-pip python${PYTHON}-dev python${PYTHON}-distutils ; fi
RUN apt-get clean && apt-get remove --purge -y \
    && rm -rf /var/lib/apt/lists/*
# Register the version in alternatives 
RUN update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON} 1 
# Set python 3 as the default python 
RUN update-alternatives --set python /usr/bin/python${PYTHON}
RUN pip3 install --upgrade pip
RUN python3 -m pip install cython psutil protobuf Pillow==6.2.2
RUN python3 -m pip install torch==${PYTORCH}+cpu torchvision==${TORCHVISION} -f https://download.pytorch.org/whl/torch_stable.html

# Install petrel oss sdk and petrel config file, make sure petrel-oss-python-sdk & openmmlab-ci exists
COPY petrel-oss-python-sdk /tmp
WORKDIR /tmp
RUN python setup.py develop
ADD openmmlab-ci/Dockerfiles/petreloss.conf /root/
RUN rm -rf petrel-oss-python-sdk

# WORKDIR /opt/mmcv
# COPY . /opt/mmcv

# RUN python setup.py develop \
#     && python3 -m pip install --no-cache-dir -e .
RUN pip install mmcv-full==${MMCV_VERSION} -f https://download.openmmlab.com/mmcv/dist/cpu/torch${PYTORCH}/index.html