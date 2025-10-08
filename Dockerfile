# ベースイメージを指定
FROM nvcr.io/nvidia/pytorch:23.10-py3

# Docker CLIとNGC CLIのインストールに必要なパッケージを追加
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    wget \
    unzip

# --- Docker CLIのインストール ---
# 1. Dockerの公式GPGキーを追加
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN chmod a+r /etc/apt/keyrings/docker.gpg

# 2. Dockerのリポジトリを設定
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# 3. Docker CLIをインストール
RUN apt-get update && apt-get install -y docker-ce-cli

# --- ここからNGC CLIのインストールを追加 ---
# 4. NGC CLIのzipファイルをダウンロード
RUN wget --content-disposition https://ngc.nvidia.com/downloads/ngccli_linux.zip -O ngccli_linux.zip && \
    # /usr/local/binに解凍
    unzip ngccli_linux.zip -d /usr/local/bin && \
    # 実行権限を付与
    chmod u+x /usr/local/bin/ngc-cli/ngc && \
    # パスを通してどこからでも 'ngc' コマンドを使えるようにする
    ln -s /usr/local/bin/ngc-cli/ngc /usr/local/bin/ngc && \
    # 不要になったzipファイルを削除
    rm ngccli_linux.zip

# 作業ディレクトリを設定
WORKDIR /workspace
