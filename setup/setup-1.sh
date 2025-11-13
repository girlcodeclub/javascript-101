#!/bin/bash
set -e

echo "🚀 Installing all VM packages..."
echo "This may take a few minutes."

sudo apt-get update && sudo apt-get install -y \
  nodejs \
  npm \
  git \
  build-essential \
  python3 \
  python3-pip \
  pkg-config \
  neovim \
  vim \
  nano \
  curl \
  wget \
  jq \
  htop \
  tree \
  unzip \
  zip \
  zsh \
  tmux \
  net-tools \
  dnsutils \
  iputils-ping \
  traceroute \
  ca-certificates \
  gnupg \
  gnupg-agent \
  scdaemon

echo "✅ All packages installed!"
