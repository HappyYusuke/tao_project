#!/bin/bash

# ==============================================================================
#  TAO PointPillars 評価実行スクリプト (Config上書き対応版)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. パス設定 (環境に合わせて変更してください)
# ------------------------------------------------------------------------------

# 評価に使用するデータセットの場所 (trainingとvalが含まれる親フォルダ)
DATA_PATH="/workspace/data/your/dataset"

# 評価結果の保存先
RESULTS_DIR="/workspace/results/eval"

# データ変換で作成した中間ファイル(.pkl)がある場所
# ※ 検証用データの変換先を指定してください (例: convert_result/eval/data_info)
DATA_INFO_PATH="/workspace/convert_result/eval/data_info"

# ★評価したいモデルファイル(.tlt)のパス
CHECKPOINT_PATH="/workspace/results/train/checkpoint_epoch_400.tlt"

# default_config.py: Car, Pedestrian, Cyclist
# pedestrian_config.py: Pedestrian
CONFIG_FILE="pedestrian_config.py"

# ------------------------------------------------------------------------------
# 2. 評価パラメータ設定
# ------------------------------------------------------------------------------

# 点群の座標範囲 (★学習時と全く同じ設定にしてください)
PC_RANGE='[-69.12, -39.68, -3, 69.12, 39.68, 1]'

# 暗号化キー
KEY="nvidia_tao"

# ------------------------------------------------------------------------------
# 3. 実行コマンド
# ------------------------------------------------------------------------------

echo "Start val..."
echo "MODEL: $CHECKPOINT_PATH"
echo "SAVE: $RESULTS_DIR"

# ★修正ポイント:
# /bin/bash -c "..." を使い、コンテナ内で cp コマンドを実行してから評価を開始する

docker run --rm --gpus all \
    --ipc=host \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    -v ${HOST_HOME}/tao_project:/workspace \
    -v ${HOST_HOME}/.ngc:/root/.ngc \
    \
    nvcr.io/nvidia/tao/tao-toolkit:5.5.0-pyt \
    \
    /bin/bash -c " \
    cp /workspace/pointpillars/config/${CONFIG_FILE} /usr/local/lib/python3.10/dist-packages/nvidia_tao_pytorch/pointcloud/pointpillars/config/default_config.py && \
    python3 /workspace/pointpillars/scripts/evaluate.py \
        --config-path /workspace/pointpillars/config \
        --config-name default_config \
        results_dir=${RESULTS_DIR} \
        dataset.data_info_path=${DATA_INFO_PATH} \
        dataset.data_path=${DATA_PATH} \
        evaluate.checkpoint=${CHECKPOINT_PATH} \
        key=${KEY} \
        dataset.info_path='{test: [infos_val.pkl]}' \
        dataset.point_cloud_range=\"${PC_RANGE}\""
