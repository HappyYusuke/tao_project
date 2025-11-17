#!/bin/bash

docker run --rm --gpus all \
    --ipc=host \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    -v /home/demulab-kohei/tao_project:/workspace \
    -v /home/demulab-kohei/.ngc:/root/.ngc \
    nvcr.io/nvidia/tao/tao-toolkit:5.5.0-pyt \
    python3 /workspace/pointpillars/scripts/evaluate.py \
        --config-path /workspace/pointpillars/config \
        --config-name default_config \
        results_dir=/workspace/results/follow_me_eval \
        dataset.data_info_path=/workspace/results/data_info \
        dataset.data_path=/workspace/data/follow_me \
        dataset.info_path='{test: [infos_val.pkl]}' \
        evaluate.checkpoint=/workspace/results/follow_me_train/checkpoint_epoch_80.tlt \
        key=nvidia_tao
