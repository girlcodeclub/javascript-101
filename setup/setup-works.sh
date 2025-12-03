#!/bin/bash
#
# Coder Web Development Environment Setup Script
#
# This script ensures necessary tools are installed, configures the student's
# Git identity, and clones their GitHub repository.

# --- Configuration ---
ORG_NAME="girlcodeclub"
REPO_FOUND=0
STUDENT_NAME=""
CLONE_DIR=""

# The create_starter_files function is removed as requested.

# 1. System Update and Package Installation (Ensuring Git, Node, NPM, etc., are present)
echo "--- 1. Checking for system updates and installing essential packages ---"
# Coder environments are often based on Debian/Ubuntu, so using apt is reliable.

# List of packages to install
# Added 'jq' (JSON processor) and 'httpie' (user-friendly HTTP client)
PACKAGES_TO_INSTALL="git nodejs npm curl tree jq httpie"
INSTALLED_PACKAGES=""

# Update the package list silently
sudo apt-get update > /dev/null 2>&1

# Check for missing packages
for PKG in $PACKAGES_TO_INSTALL; do
    if ! command -v "$PKG" &> /dev/null
    then
        INSTALLED_PACKAGES+="$PKG "
    fi
done

# Install all missing packages in one command
if [ -n "$INSTALLED_PACKAGES" ]; then
    echo "Installing required packages: $INSTALLED_PACKAGES..."
    sudo apt-get install $INSTALLED_PACKAGES -y > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install one or more packages. Please check system permissions or connectivity."
        exit 1
    fi
else
    echo "All required packages are already installed."
fi


# 2. Git Identity Configuration (NEW ADDITION)
echo ""
echo "--- 2. Setting Up Git Identity ---"
read -p "Enter your full name (for Git commits): " GIT_NAME
read -p "Enter your email address (for Git commits): " GIT_EMAIL

# Set global Git configuration
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
echo "Git identity set: Name: $GIT_NAME, Email: $GIT_EMAIL"


# 3. Interactive Repository Cloning
echo ""
echo "--- 3. Connecting to GitHub and Cloning Repository ---"
echo "Note: The system assumes your global SSH key is already configured for GitHub."

# Loop until a valid repository is successfully cloned
while [ $REPO_FOUND -eq 0 ]; do
    # Prompt user for their first name
    read -p "Please enter your first name (e.g., 'jane' for jane.git): " FIRST_NAME

    # Convert name to lowercase and remove spaces for URL construction
    STUDENT_NAME=$(echo "$FIRST_NAME" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
    CLONE_DIR="$STUDENT_NAME"

    # Construct the HTTPS URL
    REPO_URL="https://github.com/$ORG_NAME/$STUDENT_NAME"

    echo "Attempting to clone repository: $REPO_URL..."

    # Check if the directory already exists
    if [ -d "$CLONE_DIR" ]; then
        echo "Error: Directory '$CLONE_DIR' already exists. Please delete it or check your input."
        continue
    fi

    # Attempt to clone the repository using HTTPS
    git clone "$REPO_URL" "$CLONE_DIR"

    # Check the exit status of the git clone command
    if [ $? -eq 0 ]; then
        echo ""
        echo "Success! Repository '$CLONE_DIR' has been successfully cloned."
        REPO_FOUND=1
    else
        echo ""
        echo "--- Cloning Failed! ---"
        echo "Could not find a public repository at $REPO_URL."
        echo "Please check the spelling of your first name or confirm the repository exists."
        echo "-----------------------"
        echo ""
    fi
done


# 4. Final Instructions
echo ""
echo "--- 4. Setup Complete ---"
echo "Your development environment is ready."
echo ""
echo "Next Steps:"
echo "1. Change into your new project directory: \`cd $CLONE_DIR\`"
echo "2. Open your main HTML file (e.g., \`index.html\`)."
echo "3. Click the 'Go Live' button in the VS Code status bar to start the Live Server."
echo ""
echo "Happy coding!"
