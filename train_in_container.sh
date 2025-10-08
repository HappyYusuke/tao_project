#!/bin/bash

docker run --rm --gpus all \
    --ipc=host \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    -v /home/demulab-kohei/tao_project:/workspace \
    -v /home/demulab-kohei/.ngc:/root/.ngc \
    nvcr.io/nvidia/tao/tao-toolkit:5.5.0-pyt \
    python3 /workspace/pointpillars/scripts/train.py \
        --config-path /workspace/pointpillars/config \
        --config-name default_config \
        results_dir=/workspace/results/test_train \
        dataset.data_info_path=/workspace/results/data_info \
        dataset.data_path=/workspace/data/kitti \
        train.num_epochs=2 \
        train.batch_size=4 \
        dataset.data_augmentor.disable_aug_list=[gt_sampling] \
        key=nvidia_tao

