#!/bin/bash
set -e

echo "🚀 Starting the student developer environment setup..."
echo "This script will install Node.js, npm, git, and other tools."
echo ""

echo "1. Updating package lists (this might take a minute)..."
sudo apt-get update
echo "✅ Package lists updated."
echo ""

echo "2. Installing all 25 developer packages..."
echo "This will take a few minutes. Please wait..."
echo ""

export DEBIAN_FRONTEND=noninteractive
sudo apt-get install -y \
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
  gnupg

echo ""
echo "✅ All tools installed!"
echo ""
echo "---"
echo "Verifying key installations:"
echo -n "Node.js:   "
node -v
echo -n "NPM:         "
npm -v
echo -n "Git:         "
git --version
echo -n "jq:          "
jq --version
echo -n "tree:        "
tree --version
echo "---"
echo ""
echo "🎉 Setup complete! You are ready to code."
echo "You may need to restart your terminal for all changes to take effect."
