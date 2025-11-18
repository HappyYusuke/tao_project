## Discription
NVIDIA TAO Toolkitを使って、PointPillarsを学習させるためのリポジトリ。

内容
* .shファイル
  > Docker環境実行用のシェルスクリプト
* pointpillarsディレクトリ
  > NVIDIA TAO Toolkitを使用したPointPillars
* dataディレクトリ
  > データセット配置用ディレクトリフォーマットは以下を参照
<pre>
data
└── kitti
    ├── train
    │   ├── label
    │   │   └── hogehoge.txt
    │   │
    │   └── lidar
    │       └── hogehoge.bin
    └── val
        ├── label
        │   └── hogehoge.txt
        └── lidar
            └── hogehoge.bin
</pre>

## Installation
docker-composeコマンドをインストールする
```
sudo apt install -y docker-compose
```

## Usage
### ファイルツリーを作成
### ラベルファイル変換
### 点群ファイル変換
### ディレクトリ名変更
### 学習できるようにデータセットを変換
### 学習
Step1. イメージをビルド
```
./build_docker_container.sh
```

Step2. コンテナを起動
```
./run_docker_compose.sh
```

Step3. データセットの変換
```
./dataset_convert_container.sh
```

Step4. 学習
```
train_in_container.sh
```

Step5. 終了
```
stop_docker_compose.sh
```
