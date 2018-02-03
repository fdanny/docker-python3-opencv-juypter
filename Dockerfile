# Ubuntu 16.04 with python 3.5.3 with jupyter
# docker build -t fdanny/python3-net-opencv-jupyter .
# docker run -it -p 8888:8888 fdanny/python3-net-opencv-jupyter

FROM zteisberg/pythonnet:python3.5-mono4.8.0-pythonnet2.3.0
MAINTAINER Daniel Fernandez <fernandez_dan2@hotmail.com>

ENV OPENCV_VERSION="3.2.0"

RUN apt-get update && \
        apt-get install -y \
        build-essential \
        cmake \
        git \
        wget \
        unzip \
        yasm \
        pkg-config \
        libswscale-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libjasper-dev \
        libavformat-dev \
        libpq-dev

RUN pip3 install --upgrade pip \
  && pip3 install numpy \
  && pip3 install scipy \
  && pip3 install pandas \
  && pip3 install matplotlib \
  && pip3 install ipykernel \
  && pip3 install jupyter \
  && pip3 install ptpython \
  && pip3 install colormath \
  && pip3 install scikit-image
  

WORKDIR /
RUN wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
&& unzip ${OPENCV_VERSION}.zip \
&& mkdir /opencv-${OPENCV_VERSION}/cmake_binary \
&& cd /opencv-${OPENCV_VERSION}/cmake_binary \
&& cmake -DBUILD_TIFF=ON \
  -DBUILD_opencv_java=OFF \
  -DWITH_CUDA=OFF \
  -DENABLE_AVX=ON \
  -DWITH_OPENGL=ON \
  -DWITH_OPENCL=ON \
  -DWITH_IPP=ON \
  -DWITH_TBB=ON \
  -DWITH_EIGEN=ON \
  -DWITH_V4L=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=$(python3.5 -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python3.5) \
  -DPYTHON_INCLUDE_DIR=$(python3.5 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python3.5 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
&& make install \
&& rm /${OPENCV_VERSION}.zip \
&& rm -r /opencv-${OPENCV_VERSION}
  
# Set up our notebook config.
COPY support/jupyter_config.py /root/.jupyter/

# Jupyter has issues with being run directly:
#   https://github.com/ipython/ipython/issues/7062
# We just add a little wrapper script.
COPY support/jupyter_launch.sh /
RUN chmod +x /jupyter_launch.sh

# IPython
EXPOSE 8888

WORKDIR "/home"

CMD ["/jupyter_launch.sh"]
