#!/bin/bash

exists() {
  command -v "$1" >/dev/null 2>&1
}

show() {
  case $2 in
    "error") echo -e "${PINK}${BOLD}❌ $1${NORMAL}" ;;
    "progress") echo -e "${PINK}${BOLD}⏳ $1${NORMAL}" ;;
    *) echo -e "${PINK}${BOLD}✅ $1${NORMAL}" ;;
  esac
}

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
PINK='\033[1;35m'

# Cek apakah Docker terpasang, jika tidak pasang Docker
if ! exists docker; then
  show "Docker tidak ditemukan. Menginstal Docker..." "error"
  sudo apt update
  sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt update
  sudo apt install -y docker-ce
  sudo systemctl start docker
  sudo systemctl enable docker
else
  show "Docker sudah terpasang."
fi

# Cek apakah curl terpasang, jika tidak pasang curl
if ! exists curl; then
  show "curl tidak ditemukan. Menginstal..." "error"
  sudo apt update && sudo apt install curl -y < "/dev/null"
else
  show "curl sudah terpasang."
fi

# Sumberkan .bash_profile jika ada
bash_profile="$HOME/.bash_profile"
if [ -f "$bash_profile" ]; then
  show "Memuat .bash_profile..."
  . "$bash_profile"
fi

# Bersihkan terminal
clear

# Mengambil dan menjalankan script dari URL
show "Mengambil dan menjalankan..." "progress"
sleep 5
curl -s https://file.winsnip.xyz/file/uploads/Logo-winsip.sh | bash
echo "Memulai Instalasi Otomatis NEXUS"
sleep 10

# Instal Rust
show "Menginstal Rust..." "progress"
export RUSTUP_INIT_SKIP_PATH_CHECK=yes
if ! source <(wget -O - https://raw.githubusercontent.com/winsnip/Tools/refs/heads/main/cargo.sh); then
  show "Gagal menginstal Rust." "error"
  exit 1
fi

# Instal paket-paket penting
show "Menginstal paket-paket penting..." "progress"
sudo apt update && sudo apt install -y \
  iptables \
  build-essential \
  git \
  wget \
  lz4 \
  jq \
  make \
  gcc \
  nano \
  automake \
  autoconf \
  tmux \
  htop \
  nvme-cli \
  pkg-config \
  libssl-dev \
  libleveldb-dev \
  tar \
  clang \
  bsdmainutils \
  ncdu \
  unzip

# Instal Nexus CLI
show "Menginstal Nexus CLI..." "progress"
sudo curl https://cli.nexus.xyz/install.sh | sh

# Konfigurasi layanan berbasis Docker
show "Mengatur layanan berbasis Docker untuk Nexus..." "progress"

# Cek apakah container Nexus sudah berjalan, jika ya hentikan
if [ "$(docker ps -q -f name=nexus)" ]; then
  show "Menghentikan container Nexus yang sudah berjalan..." "progress"
  docker stop nexus
  docker rm nexus
fi

# Jalankan Nexus sebagai container Docker
docker run -d --name nexus \
  -v $HOME/.nexus:/root/.nexus \
  --restart unless-stopped \
  nexus-image:latest \
  /root/.nexus/network-api/clients/cli/target/release/prover beta.orchestrator.nexus.xyz

# Verifikasi container Nexus berjalan dengan baik
if [ "$(docker ps -q -f name=nexus)" ]; then
  show "Nexus berhasil berjalan di container Docker." "progress"
else
  show "Gagal menjalankan Nexus di Docker." "error"
fi
