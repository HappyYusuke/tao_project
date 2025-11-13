#!/bin/bash

docker run --rm --gpus all \
    --ipc=host \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    -v /home/demulab-kohei/tao_project:/workspace \
    -v /home/demulab-kohei/.ngc:/root/.ngc \
    nvcr.io/nvidia/tao/tao-toolkit:5.5.0-pyt \
    python3 /workspace/pointpillars/scripts/dataset_convert.py \
        --config-path /workspace/pointpillars/config \
        --config-name default_config \
        dataset.data_path=/workspace/data/follow_me \
        results_dir=/workspace/results_val \
        dataset.data_split='{test: val}'
