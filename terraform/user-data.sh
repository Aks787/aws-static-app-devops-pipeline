#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get update -y

apt-get install -y docker.io

systemctl start docker
systemctl enable docker

docker pull akshay781/my-image

docker run -d --name website -p 80:80 --restart always akshay781/my-image