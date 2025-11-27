#!/bin/bash

# ==============================================================================
#  TAO PointPillars Training Script (Resume Logic Included)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. パス設定 (環境に合わせて変更してください)
# ------------------------------------------------------------------------------

# 学習データの元フォルダ
DATA_PATH="/workspace/data/ReidPillar-HF"

# 学習結果の保存先 
RESULTS_DIR="/workspace/results/your_data_train"

# データ変換で作成した中間ファイル(.pkl)がある場所
DATA_INFO_PATH="/workspace/convert_result/train/data_info"

# configファイル名 (歩行者のみ学習したい場合: pedestrian_config)
CONFIG_NAME="default_config"

# ------------------------------------------------------------------------------
# 2. 学習パラメータ設定
# ------------------------------------------------------------------------------

# エポック数
EPOCHS=300

# バッチサイズ
BATCH_SIZE=8

# 点群の座標範囲
PC_RANGE='[-69.12, -39.68, -3, 69.12, 39.68, 1]'

# 保存する重みファイルの数
SAVE_NUM=250

# ------------------------------------------------------------------------------
# 3. Resume (再開) 設定 
# ------------------------------------------------------------------------------

# 途中から再開しますか？ ("true" または "false")
RESUME="false"

# 再開に使用するチェックポイントのパス (RESUME="true" の時のみ使われます)
RESUME_CHECKPOINT="/workspace/results/your_data_train/checkpoint_epoch_100.tlt"

# --- 自動判定ロジック (変更不要) ---
RESUME_ARG=""
if [ "${RESUME}" = "true" ]; then
    # パスが空でないかチェック
    if [ -z "${RESUME_CHECKPOINT}" ]; then
        echo "[ERROR] RESUME is set to 'true', but RESUME_CHECKPOINT path is empty."
        exit 1
    fi
    echo "--------------------------------------------------"
    echo "[RESUME MODE] Resuming training from checkpoint:"
    echo "  $RESUME_CHECKPOINT"
    echo "--------------------------------------------------"
    RESUME_ARG="train.resume_training_checkpoint_path='$RESUME_CHECKPOINT'"
else
    echo "--------------------------------------------------"
    echo "[NEW MODE] Starting training from scratch."
    echo "--------------------------------------------------"
fi

# ------------------------------------------------------------------------------
# 4. 実行コマンド
# ------------------------------------------------------------------------------

echo "Starting training..."
echo "DATA: $DATA_PATH"
echo "SAVE: $RESULTS_DIR"

docker run --rm --gpus all \
    --ipc=host \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    -v ${HOST_HOME}/tao_project:/workspace \
    -v ${HOST_HOME}/.ngc:/root/.ngc \
    nvcr.io/nvidia/tao/tao-toolkit:5.5.0-pyt \
    python3 /workspace/pointpillars/scripts/train.py \
        --config-path /workspace/pointpillars/config \
        --config-name ${CONFIG_NAME} \
        results_dir=${RESULTS_DIR} \
        dataset.data_info_path=${DATA_INFO_PATH} \
        dataset.data_path=${DATA_PATH} \
        train.num_epochs=${EPOCHS} \
        train.batch_size=${BATCH_SIZE} \
        \
        dataset.info_path='{train: [infos_train.pkl], test: [infos_val.pkl]}' \
        dataset.data_split='{train: train, test: val}' \
        \
        dataset.data_augmentor.disable_aug_list=[gt_sampling] \
        \
        dataset.point_cloud_range="${PC_RANGE}" \
        \
        ${RESUME_ARG} \
        \
        train.max_checkpoint_save_num=${SAVE_NUM}
        \
        key=nvidia_tao
