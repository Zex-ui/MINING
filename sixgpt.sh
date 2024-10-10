#!/bin/bash

curl -s https://file.winsnip.xyz/file/uploads/Logo-winsip.sh | bash
sleep 5

sudo apt update -y && sudo apt upgrade -y

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
  sudo apt-get remove -y $pkg
done

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y && sudo apt upgrade -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo chmod +x /usr/local/bin/docker-compose

docker --version

mkdir sixgpt
cd sixgpt

read -p "Masukkan VANA_PRIVATE_KEY: " 54f6955031303578c639b50ac40a12cac8799560203003658433fd94e502c5a2
read -p "Masukkan VANA_NETWORK: " satori

export VANA_PRIVATE_KEY=$VANA_PRIVATE_KEY
export VANA_NETWORK=$VANA_NETWORK

cat <<EOF > docker-compose.yml
version: '3.8'

services:
  ollama:
    image: ollama/ollama:0.3.12
    ports:
      - "11435:11434"
    volumes:
      - ollama:/root/.ollama
    restart: unless-stopped
 
  sixgpt3:
    image: sixgpt/miner:latest
    ports:
      - "3015:3000"
    depends_on:
      - ollama
    environment:
      - VANA_PRIVATE_KEY=\${54f6955031303578c639b50ac40a12cac8799560203003658433fd94e502c5a2}
      - VANA_NETWORK=\${satori}
    restart: always

volumes:
  ollama:
EOF

docker compose up -d
