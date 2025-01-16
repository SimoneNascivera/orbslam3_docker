FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu20.04

ENV ROS_DISTRO=noetic
ENV LANG=en_US.UTF-8
ARG USERNAME=docker
ARG USER_UID=1003
ARG USER_GID=$USER_UID
ENV HOME=/home/$USERNAME

ENV NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

RUN useradd -m $USERNAME && \
        echo "$USERNAME:$USERNAME" | chpasswd && \
        usermod --shell /bin/bash $USERNAME && \
        usermod -aG sudo $USERNAME && \
        mkdir -p /etc/sudoers.d && \
        echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
        chmod 0440 /etc/sudoers.d/$USERNAME && \
        # Replace 1000 with your user/group id
        usermod  --uid $USER_UID $USERNAME && \
        groupmod --gid $USER_GID $USERNAME


RUN apt-get update && apt-get install -y \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -q -y --no-install-recommends tzdata && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -q -y --no-install-recommends \
    dirmngr \
    gnupg2 \
    curl \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*


RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# install ros packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-desktop-full \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    python3-rosdep \
    python3-rosinstall \
    python3-vcstools \
    python3-catkin-tools \
    python3-catkin-pkg-modules \
    python3-rospkg-modules \
    python3-empy \
    && rm -rf /var/lib/apt/lists/*

#RUN apt install -y $(echo "$(apt install)" | awk '/no longer required:/ {found=1; next} found' | awk '/Use '\''sudo apt autoremove'\'' to remove them./ {exit} {print}') && rm -rf /var/lib/apt/lists/*

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gnupg2 \
    curl \
    lsb-core \
    vim \
    wget \
    python3-pip \
    libpng16-16 \
    libjpeg-turbo8 \
    libtiff5 \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    cmake \
    build-essential \
    git \
    unzip \
    pkg-config \
    python3-dev \
    python3-numpy \
    libgl1-mesa-dev \
    libglew-dev \
    libpython3-dev \
    libeigen3-dev \
    apt-transport-https \
    ca-certificates\
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3-dev \
    python3-numpy \
    python-dev \
    python-numpy \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer1.0-dev \
    libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*


RUN cd /tmp && git clone https://github.com/opencv/opencv.git && \
    cd opencv && \
    git checkout 4.4.0 && \
    mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=Release -D BUILD_EXAMPLES=OFF  -D BUILD_DOCS=OFF -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D CMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j$nproc && make install && \
    cd / && rm -rf /tmp/opencv

# # Build Pangolin
RUN cd /tmp && git clone https://github.com/stevenlovegrove/Pangolin && \
    cd Pangolin && git checkout v0.6 && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-std=c++11 .. && \
    make -j$nproc && make install && \
    cd / && rm -rf /tmp/Pangolin

RUN mkdir /ORB_SLAM3
WORKDIR /ORB_SLAM3

COPY ros_entrypoint.sh /ros_entrypoint.sh
RUN chmod +x  /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]

USER $USERNAME
# terminal colors with xterm
ENV TERM=xterm

CMD ["bash"]