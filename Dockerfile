FROM nvidia/cuda:12.1.0-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8

RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && apt-get install -y --no-install-recommends \
        tzdata curl wget git nano tmux \
        software-properties-common locales \
        python3 python3-pip python3-tk \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir \
    numpy==1.24.3 \
    matplotlib \
    pandas \
    pyqtgraph==0.13.3 \
    PyQt5

RUN pip3 install --no-cache-dir \
    torch torchvision --index-url https://download.pytorch.org/whl/cu121

RUN add-apt-repository universe && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
        -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu jammy main" \
        | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    apt-get update && apt-get install -y \
        ros-humble-ros-base \
        python3-argcomplete \
        python3-rosdep \
        ros-dev-tools \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
        gazebo \
        libgazebo-dev \
        ros-humble-gazebo-ros-pkgs \
        ros-humble-gazebo-ros \
        ros-humble-gazebo-plugins \
        ros-humble-turtlebot3-description \
    && rm -rf /var/lib/apt/lists/*

ENV GAZEBO_MODEL_DATABASE_URI=""
RUN mkdir -p /root/.gazebo/models/ground_plane /root/.gazebo/models/sun && \
    wget -q https://raw.githubusercontent.com/osrf/gazebo_models/master/ground_plane/model.sdf \
        -O /root/.gazebo/models/ground_plane/model.sdf && \
    wget -q https://raw.githubusercontent.com/osrf/gazebo_models/master/ground_plane/model.config \
        -O /root/.gazebo/models/ground_plane/model.config && \
    wget -q https://raw.githubusercontent.com/osrf/gazebo_models/master/sun/model.sdf \
        -O /root/.gazebo/models/sun/model.sdf && \
    wget -q https://raw.githubusercontent.com/osrf/gazebo_models/master/sun/model.config \
        -O /root/.gazebo/models/sun/model.config

RUN rosdep init && rosdep update

RUN printf '\nsource /opt/ros/humble/setup.bash\nexport ROS_DOMAIN_ID=1\nexport DRLNAV_BASE_PATH=/home/turtlebot3_drlnav\n[ -f $DRLNAV_BASE_PATH/install/setup.bash ] && source $DRLNAV_BASE_PATH/install/setup.bash\nexport GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$DRLNAV_BASE_PATH/src/turtlebot3_simulations/turtlebot3_gazebo/models\nexport TURTLEBOT3_MODEL=burger\nexport GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:$DRLNAV_BASE_PATH/src/turtlebot3_simulations/turtlebot3_gazebo/models/turtlebot3_drl_world/obstacle_plugin/lib\n' >> /root/.bashrc

WORKDIR /home/turtlebot3_drlnav
CMD ["bash"]
