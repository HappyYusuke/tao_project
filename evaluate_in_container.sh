#!/bin/bash

# ==============================================================================
#  TAO PointPillars 評価実行スクリプト
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. パス設定 (環境に合わせて変更してください)
# ------------------------------------------------------------------------------

# 評価に使用するデータセットの場所 (trainingとvalが含まれる親フォルダ)
DATA_PATH="/workspace/data/follow_me"

# 評価結果の保存先 (学習結果とは別の場所を指定すると管理しやすいです)
RESULTS_DIR="/workspace/results/follow_me_eval"

# データ変換で作成した中間ファイル(.pkl)がある場所
DATA_INFO_PATH="/workspace/results/data_info"

# ★評価したいモデルファイル(.tlt)のパス
# 学習結果フォルダの中にある、最も性能が良かったエポックのファイルを指定します
CHECKPOINT_PATH="/workspace/results/follow_me_train/checkpoint_epoch_80.tlt"

# ------------------------------------------------------------------------------
# 2. 評価パラメータ設定
# ------------------------------------------------------------------------------

# 点群の座標範囲 (★学習時と全く同じ設定にしてください)
# これが異なると、正しく検出できません
PC_RANGE='[-69.12, -39.68, -3, 69.12, 39.68, 1]'

# 暗号化キー (学習時と同じもの)
KEY="nvidia_tao"

# ------------------------------------------------------------------------------
# 3. 実行コマンド (ここから下は基本的に変更不要です)
# ------------------------------------------------------------------------------

echo "Start val..."
echo "MODEL: $CHECKPOINT_PATH"
echo "SAVE: $RESULTS_DIR"

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
        results_dir=${RESULTS_DIR} \
        dataset.data_info_path=${DATA_INFO_PATH} \
        dataset.data_path=${DATA_PATH} \
        evaluate.checkpoint=${CHECKPOINT_PATH} \
        key=${KEY} \
        \
        dataset.info_path='{test: [infos_val.pkl]}' \
        \
        dataset.point_cloud_range="${PC_RANGE}"
