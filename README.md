# tao_project
NVIDIA TAO Toolkitを使って、PointPillarsを学習させるためのリポジトリ。

内容
* .shファイル
  > Docker環境実行用のシェルスクリプト
* pointpillarsディレクトリ
  > NVIDIA TAO Toolkitを使用したPointPillars
* dataディレクトリ
  > データセット配置用ディレクト
* toolsディレクトリ
  > 点群ファイルとラベルファイルを変換するプログラムあり

<br>

# Installation
本リポジトリをクローン
```bash
git clone https://github.com/HappyYusuke/tao_project.git
```

Dockerをインストール（インストールしている場合はスキップ）
```bash
# 本リポジトリに移動
cd ~/tao_project

# Dockerをインストール
./install-docker.sh
```

docker-composeをインストール
```bash
sudo apt install -y docker-compose
```

<br>

# Usage
## Preprocessing
**1. ファイルツリーを作成** <br>
本リポジトリの`data`ディレクトリに以下のようなファイルツリーを作成してください <br>
(`kitti`の部分は任意のディレクトリ名です)。

<pre>
data
└── kitti
    ├── train
    │   ├── label
    │   │   └── hogehoge.txt
    │   └── lidar
    │       └── hogehoge.bin
    ├── val
    │   ├── label
    │   │   └── hogehoge.txt
    │   └── lidar
    │       └── hogehoge.bin
    └── test
        ├── label
        │   └── hogehoge.txt
        └── lidar
            └── hogehoge.bin
</pre>

<br>

**2. ラベルファイル変換 (json to txt)** <br>
イメージをビルド
```
./build_docker_container.sh
```

コンテナを起動 (プロンプトが`root@hoge:/workspace#`になります)
```
./run_docker_compose.sh
```

`convert_json_to_txt.py`を使用します。<br>
引数は以下の通り。
| 引数 | 初期値 | 内容 |
| --- | --- | --- |
| `-j` or `--json` | - | jsonファイルが格納されているディレクトリまでのパスを指定。 |
| `-t` or `--txt` | `txt` | 保存するディレクトリ名またはパスを指定。 |

`convert_json_to_txt.py`のパスを変更しプログラムを実行。
```bash
# toolsに移動する
cd tools

# プログラム実行
python3 convert_json_to_txt.py -j /path/to/your/json_dir
```

<br>

**3. 点群ファイル変換 (pcd to bin)** <br>
`convert_pcd_to_bin.py`を使用します。<br>
引数は以下の通り。
| 引数 | 初期値 | 内容 |
| --- | --- | --- |
| `-p` or `--pcd` | - | pcdファイルが格納されているディレクトリまでのパスを指定。 |
| `-b` or `--bin` | `bin` | 保存するディレクトリ名またはパスを指定。 |

`convert_pcd_to_bin.py`のパスを変更しプログラムを実行。
```bash
python3 convert_pcd_to_bin.py -p /path/to/your/pcd_dir
```

<br>

**4. ディレクトリ名変更** <br>
変換したファイルのディレクトリ名を`lidar`と`label`に変更し、`data`ディレクトリの自分のデータと置換する。
```bash
rm -r label/ lidar/
mv bin/ lidar
mv txt/ label
```

<br>

**5. 学習できるようにデータセットを変換** <br>
ファイル内の引数を環境に合わせて書き換える。
```bash
vim dataset_convert_in_container.sh
```

NVIDIA TAO Toolkitで学習できるようにデータセットを変換。
```bash
./dataset_convert_in_container.sh
```

<br>

## Training
ファイル内の引数を環境に合わせて書き換える。
```bash
vim train_in_container.sh
```

学習
```bash
./train_in_container.sh
```

終了
```bash
./stop_docker_compose.sh
```

<br>

## Evaluate
**1. 検証用にデータセットを変換** <br>
ファイル内の引数を環境に合わせて書き換える。
```bash
vim dataset_convert_val.sh
```

NVIDIA TAO Toolkitで検証できるようにデータセットを変換。
```bash
./dataset_convert_in_val.sh
```

<br>

**2. 検証** <br>
ファイル内の引数を環境に合わせて書き換える。
```bash
vim evaluate_in_container.sh
```

検証
```bash
./evaluate_in_container.sh
```

終了
```bash
./stop_docker_compose.sh
```
