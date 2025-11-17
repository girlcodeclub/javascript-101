#!/bin/bash
#
# Complete JavaScript-101 Student Setup Script
#
# This single script combines all setup steps:
# 1. Installs VM packages.
# 2. Gathers user info (name/email) *once*.
# 3. Sets up GPG keys and configures Git for verified commits.
# 4. Uses a PAT to clone the project (working around broken SSH).
# 5. Configures VS Code and creates initial project files.

set -e

# --- Define Colors ---
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

echo -e "${BLUE}Welcome to the Complete JavaScript-101 Setup Script!${NC}"
echo "This will install all tools, set up your Git/GPG keys, and clone your project."
echo "---"

# --- PART 1: Install VM Packages ---
echo -e "\n${BLUE}--- Part 1: Installing VM Packages ---${NC}"
echo "🚀 Installing all VM packages..."
echo "This may take a few minutes and will ask for your 'sudo' password."

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

echo -e "\n${GREEN}✅ All packages installed!${NC}"


# --- PART 2: Get User Info (ONCE) ---
echo -e "\n${BLUE}--- Part 2: Get User Information ---${NC}"
echo -e "${YELLOW}I need your GitHub information for GPG keys and Git commits.${NC}"
read -p "Enter your GitHub Email (e.g., your_email@example.com): " GIT_EMAIL
read -p "Enter your Full Name (e.g., Thalia Webb): " GIT_NAME

if [ -z "$GIT_EMAIL" ] || [ -z "$GIT_NAME" ]; then
    echo -e "${YELLOW}Error: Both email and name are required. Exiting.${NC}"
    exit 1
fi

echo "Ensuring GPG directory exists..."
mkdir -p /home/coder/.gnupg/
chmod 700 /home/coder/.gnupg/

echo "Ensuring gpg-agent is running..."
gpg-connect-agent killagent /bye
gpg-agent --daemon

echo -e "\n${YELLOW}--- ACTION 3.1: Generate GPG Key (Interactive) ---${NC}"
echo "You will now be guided through GPG key creation."
echo "Please follow the prompts:"
echo "1. Please select what kind of key you want: ${GREEN}Press Enter${NC} (for default)"
echo "2. What keysize do you want?: Type ${GREEN}4096${NC} and press Enter."
echo "3. Key is valid for?: ${GREEN}Press Enter${NC} (for '0 = key does not expire')."
echo "4. Is this correct? (y/N): Type ${GREEN}y${NC} and press Enter."
echo "5. Real name: Type your name: ${GREEN}$GIT_NAME${NC}"
echo "6. Email address: Type your email: ${GREEN}$GIT_EMAIL${NC}"
echo "7. Comment: ${GREEN}Press Enter${NC} (to leave blank)."
echo "8. Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit?: Type ${GREEN}O${NC} and press Enter."
echo "9. Passphrase: ${GREEN}Create and enter a new passphrase.${NC} You will use this to sign commits."
echo -e "${YELLOW}Press [Enter] to begin...${NC}"
read -r

gpg --full-generate-key

echo -e "\n${GREEN}GPG Key generated!${NC}"

echo -e "\n${BLUE}--- Part 3.2: Configure Git ---${NC}"
echo "Finding your new GPG Key ID..."

GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format=long "$GIT_EMAIL" | grep '^sec' | tail -n 1 | awk -F'/' '{print $2}' | awk '{print $1}')

if [ -z "$GPG_KEY_ID" ]; then
    echo -e "${YELLOW}Error: Could not automatically find your GPG Key ID.${NC}"
    echo "Please run 'gpg --list-secret-keys --keyid-format=long' manually to find it,"
    echo "then run 'git config --global user.signingkey YOUR_KEY_ID' yourself."
else
    echo "Found GPG Key ID: ${GREEN}$GPG_KEY_ID${NC}"
    echo "Configuring Git to use your name, email, and GPG key..."
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global user.signingkey "$GPG_KEY_ID"
    git config --global commit.gpgsign true
    echo -e "${GREEN}✅ Git configured for verified commits.${NC}"
fi

echo -e "\n${YELLOW}--- ACTION 3.3: Add GPG Key to GitHub ---${NC}"
echo "Finally, you must add your GPG *public* key to GitHub."
echo "Copy the entire block below (starting with '-----BEGIN PGP PUBLIC KEY BLOCK-----'):"
echo -e "${GREEN}"
gpg --armor --export "$GPG_KEY_ID"
echo -e "${NC}"
echo "1. Go to ${BLUE}https://github.com/settings/keys${NC}"
echo "2. Click ${GREEN}'New GPG key'${NC}"
echo "3. Paste the key block into the 'Key' box and save it."
echo -e "${YELLOW}Press [Enter] here after you have saved the key...${NC}"
read -r


# --- PART 4: Project Setup (PAT WORKAROUND) ---
echo -e "\n${BLUE}--- Part 4: Project Setup (PAT Workaround) ---${NC}"
echo "Next, I need a GitHub Personal Access Token (PAT) to work around"
echo "the broken SSH in this Coder environment."
echo ""
echo "1. Go to: ${BLUE}https://github.com/settings/tokens/new${NC}"
echo "2. Note: 'coder-vm-token'"
echo "3. Expiration: '90 days'"
echo "4. Scopes: Check the ${GREEN}'repo'${NC} box."
echo "5. Click 'Generate token' and copy the 'ghp_...' token."
echo ""
read -s -p "Please paste your GitHub PAT (ghp_...): " GITHUB_PAT

if [ -z "$GITHUB_PAT" ]; then
    echo -e "${YELLOW}\nError: PAT is required. Exiting.${NC}"
    exit 1
fi
echo -e "\n${GREEN}Thanks! Using your PAT to clone...${NC}"

if [ -d "javascript-101" ]; then
  echo "✅ 'javascript-101' directory already exists. Skipping clone."
else
  echo "Cloning 'javascript-101' from GitHub (using PAT)..."
  # This clones using the token, so it will not fail or ask for a password.
  git clone "https://ghp_$(echo $GITHUB_PAT | cut -d'_' -f2-)"@github.com/girlcodeclub/javascript-101.git
  echo "✅ Repo cloned."
fi

cd javascript-101
echo "Working inside $(pwd)"
echo ""


# --- PART 5: Configure VS Code & Create Files ---
echo -e "\n${BLUE}--- Part 5: Configuring Editor & Project Files ---${NC}"
echo "1. Configuring VS Code for 'Format on Save'..."

SETTINGS_DIR="$HOME/.local/share/code-server/User"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

mkdir -p "$SETTINGS_DIR"
if [ ! -f "$SETTINGS_FILE" ]; then
  echo "{}" > "$SETTINGS_FILE"
fi

if ! command -v jq &> /dev/null; then
    echo "⚠️ 'jq' command not found. Skipping VS Code config."
else
    jq '.["editor.formatOnSave"] = true | .["editor.defaultFormatter"] = "esbenp.prettier-vscode"' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    echo "✅ VS Code configured."
fi
echo ""

echo "2. Creating Week 1 project files (if they don't exist)..."

if [ -f "index.html" ]; then
  echo "✅ 'index.html' already exists. Skipping."
else
  cat << EOF > index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Personal Greeter</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <h1 id="greeting">Hello, Coder!</h1>
  <script src="script.js"></script>
</body>
</html>
EOF
  echo "✅ 'index.html' created."
fi

if [ -f "script.js" ]; then
  echo "✅ 'script.js' already exists. Skipping."
else
  cat << EOF > script.js
// 1. Find the <h1> element by its ID
const greetingElement = document.getElementById("greeting");
// 2. Ask the user for their name
const userName = prompt("What is your name?");
// 3. Change the text of the <h1> element
greetingElement.innerHTML = "Hello, " + userName + "!";
EOF
  echo "✅ 'script.js' created."
fi

if [ -f "style.css" ]; then
    echo "✅ 'style.css' already exists. Skipping."
else
  cat << EOF > style.css
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  display: grid;
  place-items: center;
  min-height: 90vh;
  background-color: #1e1e1e;
  color: #d4d4d4;
}
h1 {
    font-size: 3rem;
    font-weight: 600;
}
EOF
  echo "✅ 'style.css' created."
fi
echo ""


# --- PART 6: Final Instructions ---
echo -e "${GREEN}🎉 All automated setup is complete! 🎉${NC}"
echo ""
echo -e "${YELLOW}------------------------------------------------------${NC}"
echo -e "${YELLOW}YOUR FINAL STEP (THE TEST DRIVE):${NC}"
echo ""
echo "1. Open 'index.html' in your editor."
echo "2. Click the 'Go Live' button in the bottom-right corner."
echo "3. Coder will pop-up a link. Click it to open your site."
echo "4. Make a change, save the file, and watch your site auto-refresh!"
echo ""
echo -e "${YELLOW}To PUSH your work:${NC}"
echo "1. ${GREEN}git add .${NC}"
echo "2. ${GREEN}git commit -m 'your message'${NC} (It will ask for your GPG passphrase)"
echo "3. ${GREEN}git push${NC} (It will use your PAT and just work. No more SSH errors.)"
echo -e "${YELLOW}------------------------------------------------------${NC}"
