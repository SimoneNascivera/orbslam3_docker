# UI permisions
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

xhost +local:docker

# If orbslam3 exists, start it. Otherwise, create a new container
if [ "$(docker container ls --all | grep orbslam3)" ]; then
    docker start orbslam3 
    docker exec -it orbslam3 bash
else
    # Create a new container
    docker run -it --privileged --net=host --ipc=host \
        --name="orbslam3" \
        -e "DISPLAY=$DISPLAY" \
        -e "QT_X11_NO_MITSHM=1" \
        -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        -e "XAUTHORITY=$XAUTH" \
        -e ROS_IP=127.0.0.1 \
        --cap-add=SYS_PTRACE \
        -v `pwd`/Datasets:/Datasets \
        -v /etc/group:/etc/group:ro \
        -v `pwd`/ORB_SLAM3:/ORB_SLAM3 \
        orbslam3_docker bash
fi

