#!/bin/bash

# ==============================================================================
#  TAO PointPillars エクスポート実行スクリプト (TLT -> ONNX)
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. 設定 (環境に合わせて変更してください)
# ------------------------------------------------------------------------------

# ★入力: 学習済みモデルファイル (.tlt) のパス
# (学習結果フォルダの中にある checkpoint_epoch_100.tlt などを指定)
INPUT_MODEL="/workspace/results/train/checkpoint_epoch_100.tlt"

# ★出力: ONNXファイルの保存先ディレクトリ
EXPORT_DIR="/workspace/results/export_epoch100"

# ★出力: ONNXファイルの名前
ONNX_FILENAME="epoch100.onnx"

# default_config.py: Car, Pedestrian, Cyclist
# pedestrian_config.py: Pedestrian
CONFIG_FILE="pedestrian_config.py" 


# 暗号化キー (学習時と同じもの)
KEY="nvidia_tao"

# ------------------------------------------------------------------------------
# 2. 実行コマンド
# ------------------------------------------------------------------------------

# 出力ディレクトリの作成 (ホスト側のパスに変換して作成)
# ※ /workspace はコンテナ内のパスなので、ここでは相対パスや変数を利用して対応
mkdir -p ~/tao_project/results/export

echo "エクスポートを開始します..."
echo "入力モデル: $INPUT_MODEL"
echo "出力先: $EXPORT_DIR/$ONNX_FILENAME"

docker run --rm --gpus all \
    --ipc=host \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    -v ${HOST_HOME}/tao_project:/workspace \
    -v ${HOST_HOME}/.ngc:/root/.ngc \
    nvcr.io/nvidia/tao/tao-toolkit:5.5.0-pyt \
    \
    /bin/bash -c " \
    cp /workspace/pointpillars/config/${CONFIG_FILE} /usr/local/lib/python3.10/dist-packages/nvidia_tao_pytorch/pointcloud/pointpillars/config/default_config.py && \
    python3 /workspace/pointpillars/scripts/export.py \
        --config-path /workspace/pointpillars/config \
        --config-name default_config \
        key=${KEY} \
        \
        export.checkpoint=${INPUT_MODEL} \
        export.onnx_file=${EXPORT_DIR}/${ONNX_FILENAME} \
        \
        dataset.data_path='/workspace/data/HARRP' \
        dataset.point_cloud_range='[-69.12, -39.68, -3, 69.12, 39.68, 1]'"
