#!/bin/bash

# ==============================================================================
#  TAO PointPillars データ変換実行スクリプト (検証用: val -> .pkl)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. パス設定
# ------------------------------------------------------------------------------

# 変換元のデータセットがある親フォルダ
DATA_PATH="/workspace/data/your/dataset"

# 変換結果(.pklファイル)の保存先
RESULTS_DIR="/workspace/convert_result/eval"

# default_config.py: Car, Pedestrian, Cyclist
# pedestrian_config.py: Pedestrian
CONFIG_FILE="pedestrian_config.py"

# ------------------------------------------------------------------------------
# 2. 実行コマンド
# ------------------------------------------------------------------------------

echo "Start convert..."
echo "DATA: $DATA_PATH"
echo "SAVE: $RESULTS_DIR"

docker run --rm --gpus all \
    --ipc=host \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    -v ${HOST_HOME}/tao_project:/workspace \
    -v ${HOST_HOME}/.ngc:/root/.ngc \
    nvcr.io/nvidia/tao/tao-toolkit:5.5.0-pyt \
    /bin/bash -c " \
    cp /workspace/pointpillars/config/${CONFIG_FILE} /usr/local/lib/python3.10/dist-packages/nvidia_tao_pytorch/pointcloud/pointpillars/config/default_config.py && \
    python3 /workspace/pointpillars/scripts/dataset_convert.py \
        --config-path /workspace/pointpillars/config \
        --config-name default_config \
        dataset.data_path=${DATA_PATH} \
        results_dir=${RESULTS_DIR} \
        \
        dataset.data_split='{test: val}'"
