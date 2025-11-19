#!/bin/bash

# ==============================================================================
#  TAO PointPillars 学習実行スクリプト
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. パス設定 (環境に合わせて変更してください)
# ------------------------------------------------------------------------------

# 学習データの元フォルダ
DATA_PATH="/workspace/data/your_data"

# 学習結果の保存先 
RESULTS_DIR="/workspace/results/your_data_train"

# データ変換で作成した中間ファイル(.pkl)がある場所
DATA_INFO_PATH="/workspace/convert_result/train/data_info"

# ------------------------------------------------------------------------------
# 2. 学習パラメータ設定
# ------------------------------------------------------------------------------

# エポック数 (学習を回す回数)
# テスト時は2、本番は80以上を推奨
EPOCHS=80

# バッチサイズ (GPUメモリに合わせて調整)
# メモリ不足でエラーが出る場合は小さくしてください (例: 2)
BATCH_SIZE=4

# 点群の座標範囲 [x_min, y_min, z_min, x_max, y_max, z_max]
# センサーの後ろ側(マイナス)も含むように設定済み
PC_RANGE='[-69.12, -39.68, -3, 69.12, 39.68, 1]'

# ------------------------------------------------------------------------------
# 3. 実行コマンド (ここから下は基本的に変更不要です)
# ------------------------------------------------------------------------------

echo "Start train..."
echo "DATA: $DATA_PATH"
echo "SAVE: $RESULTS_DIR"

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
        results_dir=${RESULTS_DIR} \
        dataset.data_info_path=${DATA_INFO_PATH} \
        dataset.data_path=${DATA_PATH} \
        train.num_epochs=${EPOCHS} \
        train.batch_size=${BATCH_SIZE} \
        \
        dataset.info_path='{train: [infos_train.pkl]}' \
        dataset.data_split.train=training \
        \
        dataset.data_augmentor.disable_aug_list=[gt_sampling] \
        \
        dataset.point_cloud_range="${PC_RANGE}" \
        \
        key=nvidia_tao
