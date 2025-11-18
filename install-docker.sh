#!/bin/bash
sudo -E apt-get update
sudo -E apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
sudo -E curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo -E apt-key fingerprint 0EBFCD88
sudo -E add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo -E apt-get update
sudo -E apt-get install -y docker-ce
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sudo -E curl -L "https://github.com/docker/compose/releases/download/"$COMPOSE_VERSION"/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo -E chmod +x /usr/local/bin/docker-compose
sudo -E ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo -E docker run hello-world

# コンテナ内でctrl-pを二度押ししなくて良くなる設定
mkdir /home/$USER/.docker/
echo -e '{\n    "detachKeys": "ctrl-\\\\"\n}\n' >> /home/$USER/.docker/config.json

#nvidia環境でgpusオプションが扱えるようになるコード。Intel環境に入れても無駄だけどエラーは起こさないみたい。
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
sudo -E curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
sudo -E curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo -E apt-get update && sudo apt-get install -y nvidia-container-toolkit

#dockerをパスワードなしで動作するよう設定
sudo -E gpasswd -a $USER docker
sudo -E service docker restart
echo "sudo無しでdockerコマンドを使用するには、コンピューターを再起動してください。"

#参考文献
# 最新版のdocker-composeの取得
# https://thr3a.hatenablog.com/entry/20190328/1553730108
# ctrl-pを二度押ししなくて良くなる設定
# gpusオプション向け
# https://github.com/NVIDIA/nvidia-docker
