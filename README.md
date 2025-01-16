# ORB_SLAM3 docker

This docker is based on <b>Ros Noetic Ubuntu 20</b>.
---

## Compilation and Running

Steps to compile the Orbslam3 on the sample dataset:

- `./download_dataset_sample.sh`
- `./build_docker.sh`

Run the docker container:
- `./run_docker.sh`

Run an example (after download_dataset_sample.sh command):
- `cd /ORB_SLAM3/Examples/Monocular && ./Monocular/mono_euroc ../Vocabulary/ORBvoc.txt ./Monocular/EuRoC.yaml /Datasets/EuRoC/MH01 ./Monocular/EuRoC_TimeStamps/MH01.txt dataset-MH01_mono`
