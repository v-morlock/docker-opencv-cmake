FROM ubuntu:focal

LABEL maintener="Maximilian Zinke <me@mxzinke.dev>"

WORKDIR /dependencies/

# Install OpenCV dependancies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
  apt-get install -y build-essential curl wget git pkg-config libgtk-3-dev \
  libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
  libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
  gfortran openexr libatlas-base-dev python3-dev python3-numpy \
  libtbb2 libtbb-dev libdc1394-22-dev

# install CMake
RUN apt-get remove --purge --auto-remove cmake
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null
RUN echo 'deb https://apt.kitware.com/ubuntu/ focal main' >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y cmake

# Install OpenCV
RUN apt-get install unzip

RUN curl -LO https://github.com/opencv/opencv_contrib/archive/4.5.0.zip \
  && unzip 4.5.0.zip \
  && rm 4.5.0.zip
RUN curl -LO https://github.com/opencv/opencv/archive/4.5.0.zip \
  && unzip 4.5.0.zip \
  && rm 4.5.0.zip
RUN mkdir -p /dependancies/opencv-4.5.0/build && cd /dependancies/opencv-4.5.0/build
RUN cmake /dependancies/opencv-4.5.0/ -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_INSTALL_PREFIX=/usr/local \
  -D OPENCV_GENERATE_PKGCONFIG=ON \
  -D OPENCV_EXTRA_MODULES_PATH=/dependancies/opencv_contrib-4.5.0/modules
RUN cmake --build .
# optimized for 4 cores!
RUN make -j4
RUN make install
RUN rm -r /dependancies/opencv-4.5.0 \
  && rm -r /dependancies/opencv_contrib-4.5.0
