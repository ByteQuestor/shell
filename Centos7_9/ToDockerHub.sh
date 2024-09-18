#!/bin/bash

# -------------------- 使用须知 -------------------
echo "#################### 使用须知 ####################"
echo "1. 确保虚拟机能够联网，可通过 ping qq.com 验证。"
echo "2. 必须去最下面修改为自己的代理。"
echo "3. 应当运行在 CentOS 7.9 上。"
echo "4. 确保能够通过阿里镜像和腾讯镜像作为 yum 源安装 Docker。"
echo "5. 中途有失败的地方，手工补上,脚本会配好环境"
echo "###################################################"

# 等待用户按下回车键继续
read -p "先看以上说明,然后按下回车执行 " key

# 配置阿里云
systemctl stop firewalld
systemctl disable firewalld
rm -rf /etc/yum.repos.d/*
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
curl -o /etc/yum.repos.d/docker-ce.repo https://mirrors.cloud.tencent.com/docker-ce/linux/centos/docker-ce.repo 
yum makecache
yum install epel-release

# 接下来是安装docker
yum install -y docker-ce
systemctl start docker
systemctl enable docker
docker info

# 配DNS
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/systemd/system/docker.service.d/override.conf <<-'EOF'
[Service]
Environment="HTTPS_PROXY=http://192.168.100.1:13038"
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker

# ---------------- 代理设置 ----------------
# ------------- 配置自己的代理 -------------
# 在这里配置代理
# echo "export PROXY='192.168.100.1'" >> ~/.bashrc
echo "export http_proxy='http://192.168.100.1:13038'" >> ~/.bashrc
echo "export https_proxy='https://192.168.100.1:13038'" >> ~/.bashrc
echo "export no_proxy='localhost,127.0.0.1'" >> ~/.bashrc
source ~/.bashrc
echo "http_proxy=" + $http_proxy
echo "https_proxy=" + $https_proxy
curl google.com