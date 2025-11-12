#!/bin/bash
#
# GitHub SSH & GPG Key Setup Script
# This script guides a user through generating and configuring
# both key types for use with GitHub.

# --- Define Colors ---
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

echo -e "${BLUE}Welcome to the GitHub Key Setup Script!${NC}"
echo "This will set up your SSH key (for cloning) and GPG key (for verified commits)."
echo "---"

# --- 1. Get User Info ---
echo -e "${YELLOW}First, I need your GitHub information.${NC}"
read -p "Enter your GitHub Email (e.g., your_email@example.com): " GIT_EMAIL
read -p "Enter your Full Name (e.g., Thalia Webb): " GIT_NAME

if [ -z "$GIT_EMAIL" ] || [ -z "$GIT_NAME" ]; then
    echo -e "${YELLOW}Error: Both email and name are required. Exiting.${NC}"
    exit 1
fi

echo -e "\n${GREEN}Great. Using Email: $GIT_EMAIL and Name: $GIT_NAME${NC}\n"


# --- 2. SSH Key Generation (Automated) ---
echo -e "${BLUE}--- Part 1: SSH Key (Authentication) ---${NC}"
echo "Generating a new ED25519 SSH key..."
# -f specifies the file, -N "" provides an empty passphrase
ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f ~/.ssh/id_ed25519 -N "" > /dev/null

echo "Starting ssh-agent and adding your new key..."
eval "$(ssh-agent -s)" > /dev/null
ssh-add ~/.ssh/id_ed25519

echo -e "\n${YELLOW}--- ACTION 1.1: Add SSH Key to GitHub ---${NC}"
echo "Copy the entire block below (starting with 'ssh-ed25519...'):"
echo -e "${GREEN}"
cat ~/.ssh/id_ed25519.pub
echo -e "${NC}"
echo "1. Go to ${BLUE}https://github.com/settings/keys${NC}"
echo "2. Click ${GREEN}'New SSH key'${NC}"
echo "3. Give it a title (e.g., 'Class VM')."
echo "4. Paste the key into the 'Key' box and save it."
echo -e "${YELLOW}Press [Enter] here after you have saved the key on GitHub...${NC}"
read -r

echo "Adding GitHub.com to your known hosts..."
mkdir -p ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null

echo "Testing SSH connection..."
ssh -T git@github.com


# --- 3. GPG Key Generation (Guided) ---
echo -e "\n${BLUE}--- Part 2: GPG Key (Verification) ---${NC}"
echo "Checking for GPG tools..."

# Check for gpg-agent and install if missing (Debian/Ubuntu)
if ! command -v gpg-agent &> /dev/null; then
    echo -e "${YELLOW}gpg-agent not found. Attempting to install 'gnupg-agent'...${NC}"
    if command -v apt &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y gnupg-agent
    else
        echo -e "${YELLOW}Could not find 'apt'. Please install 'gnupg-agent' (or equivalent) manually and re-run.${NC}"
        exit 1
    fi
fi

echo "Ensuring gpg-agent is running..."
# Stop any old agents and start a new one to fix common VM issues
gpg-connect-agent killagent /bye > /dev/null 2>&1
gpg-agent --daemon > /dev/null

echo -e "\n${YELLOW}--- ACTION 2.1: Generate GPG Key (Interactive) ---${NC}"
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

# Run the interactive generation command
gpg --full-generate-key

echo -e "\n${GREEN}GPG Key generated!${NC}"


# --- 4. Git Configuration (Automated) ---
echo -e "\n${BLUE}--- Part 3: Configure Git ---${NC}"
echo "Finding your new GPG Key ID..."

# Automatically find the new GPG Key ID
# This parses the output of gpg --list-secret-keys
GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format=long "$GIT_EMAIL" | grep sec | awk -F'/' '{print $2}' | awk '{print $1}')

if [ -z "$GPG_KEY_ID" ]; then
    echo -e "${YELLOW}Error: Could not automatically find your GPG Key ID.${NC}"
    echo "Please run 'gpg --list-secret-keys --keyid-format=long' manually to find it,"
    echo "then run 'git config --global user.signingkey YOUR_KEY_ID' yourself."
else
    echo "Found GPG Key ID: ${GREEN}$GPG_KEY_ID${NC}"
    echo "Configuring Git to use your key and sign all commits..."
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global user.signingkey "$GGPG_KEY_ID"
    git config --global commit.gpgsign true
fi

echo -e "\n${YELLOW}--- ACTION 3.1: Add GPG Key to GitHub ---${NC}"
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

# --- 5. Finish ---
echo -e "\n${GREEN}🎉 All Done! 🎉${NC}"
echo "Your system is fully configured to push to GitHub with SSH and create verified commits with GPG."
echo "When you make a commit, you will be prompted for the GPG passphrase you created."
