## Discription
NVIDIA TAO Toolkitを使って、PointPillarsを学習させるためのリポジトリ。

内容
* .shファイル
* 

## Installation
docker-composeコマンドをインストールする
```
sudo apt install -y docker-compose
```

## Usage
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
