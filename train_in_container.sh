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
        results_dir=/workspace/results/follow_me_train \
        dataset.data_info_path=/workspace/results/data_info \
        dataset.data_path=/workspace/data/follow_me \
        train.num_epochs=80 \
        train.batch_size=4 \
        dataset.info_path='{train: [infos_train.pkl]}' \
        key=nvidia_tao \
        dataset.data_augmentor.disable_aug_list=[gt_sampling] \
        dataset.point_cloud_range='[-69.12, -39.68, -3, 69.12, 39.68, 1]'
