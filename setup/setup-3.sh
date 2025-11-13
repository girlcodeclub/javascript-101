#!/bin/bash
#
# Final Project Setup Script (PAT WORKAROUND)
# This script must be run AFTER the other two setup scripts.
#
# This script works around Coder's broken 'gitssh' helper by
# cloning and pushing using a GitHub Personal Access Token (PAT)
# over HTTPS. It still respects the GPG signing key set up in
# '2_github_setup_fixed.sh'.

set -e

echo "🚀 Starting the final project setup..."
echo "This script will clone your repo, configure Git, and set up VS Code."
echo "---"

# --- 1. Get User Input ---
echo "First, I need your name and email for your Git commits."
read -p "Please enter your Full Name (e.g., Ada Lovelace): " git_name
read -p "Please enter your GitHub Email (the one you verified): " git_email
echo ""
echo "---"
echo "Next, I need a GitHub Personal Access Token (PAT) to work around"
echo "the broken SSH in this Coder environment."
echo ""
echo "1. Go to: https://github.com/settings/tokens/new"
echo "2. Note: 'coder-vm-token'"
echo "3. Expiration: '90 days'"
echo "4. Scopes: Check the 'repo' box."
echo "5. Click 'Generate token' and copy the 'ghp_...' token."
echo ""
read -s -p "Please paste your GitHub PAT (ghp_...): " GITHUB_PAT

if [ -z "$GITHUB_PAT" ]; then
    echo "Error: PAT is required. Exiting."
    exit 1
fi
echo ""
echo "Thanks, $git_name!"
echo ""

# --- 2. Clone Project Repo (Using PAT) ---
if [ -d "javascript-101" ]; then
  echo "✅ 'javascript-101' directory already exists. Skipping clone."
else
  echo "1. Cloning 'javascript-101' from GitHub (using PAT)..."
  # This clones using the token, so it will not fail or ask for a password.
  git clone "https://ghp_$(echo $GITHUB_PAT | cut -d'_' -f2-)"@github.com/girlcodeclub/javascript-101.git
  echo "✅ Repo cloned."
fi

cd javascript-101
echo "Working inside $(pwd)"
echo ""


# --- 3. Configure Git (Name/Email ONLY) ---
echo "2. Configuring Git with your name and email..."
# Your '2_github_setup_fixed.sh' already handled the signing key.
git config --global user.name "$git_name"
git config --global user.email "$git_email"
echo "✅ Git configured."
echo ""


# --- 4. Configure VS Code ---
echo "3. Configuring VS Code for 'Format on Save'..."

SETTINGS_DIR="$HOME/.local/share/code-server/User"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

mkdir -p "$SETTINGS_DIR"
if [ ! -f "$SETTINGS_FILE" ]; then
  echo "{}" > "$SETTINGS_FILE"
fi

if ! command -v jq &> /dev/null; then
    echo "⚠️ 'jq' command not found. Skipping VS Code config."
    echo "Please make sure you ran '1_setup_student_vm.sh' first!"
else
    jq '.["editor.formatOnSave"] = true | .["editor.defaultFormatter"] = "esbenp.prettier-vscode"' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    echo "✅ VS Code configured."
fi
echo ""


# --- 5. Create Week 1 Files ---
echo "4. Creating Week 1 project files (if they don't exist)..."

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


# --- 6. Final Instructions ---
echo "🎉 All automated setup is complete!"
echo ""
echo "------------------------------------------------------"
echo "YOUR FINAL STEP (THE TEST DRIVE):"
echo ""
echo "1. Open 'index.html' in your editor."
echo "2. Click the 'Go Live' button in the bottom-right corner."
echo "3. Coder will pop-up a link. Click it to open your site."
echo "4. Make a change, save the file, and watch your site auto-refresh!"
echo ""
echo "To PUSH your work:"
echo "1. git add ."
echo "2. git commit -m 'your message' (It will ask for your GPG passphrase)"
echo "3. git push (It will use your PAT and just work. No more SSH errors.)"
echo "------------------------------------------------------"
