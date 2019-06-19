ARG CUDA_IMAGE_TAG=9.2-cudnn7-devel-ubuntu16.04
FROM nvidia/cuda:${CUDA_IMAGE_TAG}


ARG MKL_VERSION=2019.3-062
ARG PYTHON_VERSION=3.7.3

LABEL python.version=$PYTHON_VERSION \
      mkl.version=$MKL_VERSION \
      maintainer="Yusuke Nakashima <pixy2001@gmail.com>"

RUN apt-get update \
    && apt-get install -y --no-install-recommends wget ca-certificates \
    && wget -qO- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB | apt-key add - \
    && echo 'deb https://apt.repos.intel.com/mkl all main' > /etc/apt/sources.list.d/intel-mkl.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        intel-mkl.${MKL_VERSION} \
        libssl-dev libffi-dev libsqlite3-dev \
        gfortran \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV MKL_ROOT_DIR /opt/intel/mkl
ENV LD_LIBRARY_PATH $MKL_ROOT_DIR/lib/intel64

RUN mkdir -p /src/python \
    && cd /src/python \
    && wget -qO- https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz | tar xzf - --strip-components=1 \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && cd .. && rm -rf /src/python

ENV PATH /usr/local/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/lib:$LD_LIBRARY_PATH
ENV INCLUDE_PATH /usr/local/include:$INCLUDE_PATH

ADD numpy-site.cfg /root/.numpy-site.cfg

RUN pip3 install --no-binary :all: numpy scipy
