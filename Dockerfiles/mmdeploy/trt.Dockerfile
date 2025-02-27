ARG IMAGE="ubuntu_1804_py_39_cuda_111_cudnn_8_torch_190"
ARG BACKEND="trt"
ARG TAG="v1"
ARG TENSORRT_VERSION="8.0.3.4"
# ARG MMCV_VERSION="v1.4.4"

FROM registry.sensetime.com/mmdeploy/${IMAGE}_${BACKEND}:${TAG}
ARG HTTP_PROXY="http://proxy.sensetime.com:3128"
ARG DEBIAN_FRONTEND=noninteractive
ARG TENSORRT_VERSION
ARG BACKEND

ENV TZ=Asia/Shanghai
ENV HTTP_PROXY="$HTTP_PROXY"
ENV HTTPS_PROXY="$HTTP_PROXY"
ENV TENSORRT_DIR="/opt/deps/TensorRT-${TENSORRT_VERSION}"
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$TENSORRT_DIR/lib

RUN echo $LD_LIBRARY_PATH && echo $TENSORRT_DIR
WORKDIR /opt/mmdeploy
COPY . /opt/mmdeploy

RUN git submodule update --init --recursive
RUN pip install --upgrade pip && pip install -r requirements.txt && pip install -e .
RUN mkdir build && cd build \
    && cmake .. \
   -DMMDEPLOY_BUILD_SDK=ON \
   -DCMAKE_CXX_COMPILER=g++-7 \
   -Dpplcv_DIR=/opt/deps/ppl.cv/cuda-build/install/lib/cmake/ppl \
   -DTENSORRT_DIR=${TENSORRT_DIR} \
#    -DCUDNN_DIR=/path/to/cudnn \
   -DMMDEPLOY_TARGET_DEVICES="cuda;cpu" \
   -DMMDEPLOY_TARGET_BACKENDS=${BACKEND} \
   -DMMDEPLOY_BUILD_SDK_PYTHON_API=ON \
   -DMMDEPLOY_CODEBASES=all \
    && cmake --build . -- -j4 && cmake --install .
# RUN python tools/check_env.py