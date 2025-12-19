#!/bin/bash

###########################################
# SAFE Node.js Cleanup & Reinstall Script
# Does NOT kill running processes
###########################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo ""
echo "================================================"
echo "  Complete Node.js Cleanup & Reinstall"
echo "================================================"
echo ""

# Check if Node processes are running
if pgrep -x "node" > /dev/null; then
    echo -e "${YELLOW}WARNING:${NC} Node.js processes are running!"
    echo "Please close all Node.js applications and try again."
    echo ""
    echo "Running processes:"
    ps aux | grep -E "node" | grep -v grep | awk '{print "  "$2, $11, $12, $13, $14}'
    echo ""
    read -p "Continue anyway? (yes/no): " force
    if [ "$force" != "yes" ]; then
        echo "Cancelled. Please close Node apps and run again."
        exit 0
    fi
fi

# Confirm
echo -e "${YELLOW}This will remove:${NC}"
echo "  • Node.js"
echo "  • npm"
echo "  • nvm"
echo "  • yarn"
echo "  • pnpm"
echo "  • All global packages"
echo "  • All cache files"
echo ""
read -p "Continue? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Starting cleanup..."
echo ""

# ============================================
# STEP 1: Backup (optional)
# ============================================
echo -e "${BLUE}[1/10]${NC} Creating backup of global packages..."

if command -v npm &> /dev/null; then
    BACKUP_DIR="$HOME/node-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    echo "  Saving list of global packages..."
    npm list -g --depth=0 > "$BACKUP_DIR/global-packages.txt" 2>/dev/null || true

    echo -e "${GREEN}✓${NC} Backup saved to: $BACKUP_DIR"
else
    echo -e "${YELLOW}!${NC} npm not found, skipping backup"
fi

# ============================================
# STEP 2: Remove via package managers
# ============================================
echo -e "${BLUE}[2/10]${NC} Removing Node.js via package managers..."

# APT (Debian/Ubuntu)
if command -v apt-get &> /dev/null; then
    echo "  Removing via apt..."
    sudo apt-get remove --purge -y nodejs npm 2>/dev/null || true
    sudo apt-get autoremove -y 2>/dev/null || true
fi

# YUM (RHEL/CentOS)
if command -v yum &> /dev/null; then
    echo "  Removing via yum..."
    sudo yum remove -y nodejs npm 2>/dev/null || true
fi

# DNF (Fedora)
if command -v dnf &> /dev/null; then
    echo "  Removing via dnf..."
    sudo dnf remove -y nodejs npm 2>/dev/null || true
fi

# Homebrew (macOS)
if command -v brew &> /dev/null; then
    echo "  Removing via brew..."
    brew uninstall --force node 2>/dev/null || true
    brew cleanup 2>/dev/null || true
fi

# Snap
if command -v snap &> /dev/null; then
    echo "  Removing via snap..."
    sudo snap remove node 2>/dev/null || true
fi

echo -e "${GREEN}✓${NC} Package managers cleaned"

# ============================================
# STEP 3: Remove NVM
# ============================================
echo -e "${BLUE}[3/10]${NC} Removing NVM..."

export NVM_DIR=""
rm -rf ~/.nvm
rm -rf ~/.config/nvm

# Clean shell configs
for file in ~/.bashrc ~/.zshrc ~/.profile ~/.bash_profile; do
    if [ -f "$file" ]; then
        cp "$file" "${file}.backup-$(date +%Y%m%d)"
        sed -i '/NVM_DIR/d' "$file" 2>/dev/null || true
        sed -i '/nvm.sh/d' "$file" 2>/dev/null || true
        sed -i '/bash_completion/d' "$file" 2>/dev/null || true
    fi
done

echo -e "${GREEN}✓${NC} NVM removed"

# ============================================
# STEP 4: Remove other version managers
# ============================================
echo -e "${BLUE}[4/10]${NC} Removing other version managers..."

# n
sudo rm -rf /usr/local/n 2>/dev/null || true
sudo rm -f /usr/local/bin/n 2>/dev/null || true

# fnm
rm -rf ~/.local/share/fnm 2>/dev/null || true
rm -rf ~/.fnm 2>/dev/null || true

# volta
rm -rf ~/.volta 2>/dev/null || true

echo -e "${GREEN}✓${NC} Version managers removed"

# ============================================
# STEP 5: Remove cache directories
# ============================================
echo -e "${BLUE}[5/10]${NC} Removing cache directories..."

rm -rf ~/.npm
rm -rf ~/.node-gyp
rm -rf ~/.cache/node
rm -rf ~/.cache/npm
rm -rf ~/.config/configstore

echo -e "${GREEN}✓${NC} Cache cleaned"

# ============================================
# STEP 6: Remove package managers
# ============================================
echo -e "${BLUE}[6/10]${NC} Removing yarn and pnpm..."

# Yarn
rm -rf ~/.yarn
rm -rf ~/.yarnrc
sudo rm -f /usr/local/bin/yarn 2>/dev/null || true
sudo rm -f /usr/local/bin/yarnpkg 2>/dev/null || true

# pnpm
rm -rf ~/.pnpm-store
rm -rf ~/.local/share/pnpm
sudo rm -f /usr/local/bin/pnpm 2>/dev/null || true

echo -e "${GREEN}✓${NC} Package managers removed"

# ============================================
# STEP 7: Remove system directories
# ============================================
echo -e "${BLUE}[7/10]${NC} Removing system directories..."

sudo rm -rf /usr/local/lib/node*
sudo rm -rf /usr/local/include/node*
sudo rm -rf /usr/local/share/man/man1/node*
sudo rm -rf /usr/lib/node_modules
sudo rm -rf /usr/share/doc/nodejs
sudo rm -rf /opt/local/bin/node
sudo rm -rf /opt/local/include/node
sudo rm -rf /opt/local/lib/node_modules

echo -e "${GREEN}✓${NC} System directories cleaned"

# ============================================
# STEP 8: Remove binaries
# ============================================
echo -e "${BLUE}[8/10]${NC} Removing binaries..."

sudo rm -f /usr/local/bin/node
sudo rm -f /usr/local/bin/nodejs
sudo rm -f /usr/local/bin/npm
sudo rm -f /usr/local/bin/npx
sudo rm -f /usr/bin/node
sudo rm -f /usr/bin/nodejs
sudo rm -f /usr/bin/npm
sudo rm -f /usr/bin/npx
sudo rm -f /usr/sbin/node

echo -e "${GREEN}✓${NC} Binaries removed"

# ============================================
# STEP 9: Verify cleanup
# ============================================
echo -e "${BLUE}[9/10]${NC} Verifying cleanup..."

if command -v node &> /dev/null; then
    echo -e "${YELLOW}!${NC} Warning: node still found at $(which node)"
else
    echo -e "${GREEN}✓${NC} Node.js removed"
fi

if command -v npm &> /dev/null; then
    echo -e "${YELLOW}!${NC} Warning: npm still found at $(which npm)"
else
    echo -e "${GREEN}✓${NC} npm removed"
fi

# ============================================
# STEP 10: Install fresh NVM + Node LTS
# ============================================
echo -e "${BLUE}[10/10]${NC} Installing NVM and Node.js LTS..."

# Install NVM
echo "  Downloading NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Load NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Install Node LTS
echo "  Installing Node.js LTS..."
nvm install --lts
nvm alias default lts/*
nvm use default

# Update npm
echo "  Updating npm..."
npm install -g npm@latest

echo -e "${GREEN}✓${NC} Installation complete"

# ============================================
# Summary
# ============================================
echo ""
echo "================================================"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo "================================================"
echo ""
echo "Installed versions:"
echo "  Node.js: $(node --version)"
echo "  npm:     $(npm --version)"
echo "  nvm:     $(nvm --version)"
echo ""
echo "Installation paths:"
echo "  NVM:  $NVM_DIR"
echo "  Node: $(which node)"
echo "  npm:  $(which npm)"
echo ""

if [ -d "$BACKUP_DIR" ]; then
    echo -e "${YELLOW}Backup:${NC} $BACKUP_DIR"
    echo ""
fi

# Optional packages
read -p "Install global packages (yarn, typescript, ts-node)? (y/n): " install_global

if [ "$install_global" = "y" ]; then
    echo ""
    echo "Installing global packages..."
    npm install -g yarn typescript ts-node
    echo -e "${GREEN}✓${NC} Global packages installed"
fi

# Create helper script
cat > ~/node-helper.sh << 'HELPER'
#!/bin/bash
echo "╔════════════════════════════════════════╗"
echo "║     Node.js Quick Commands             ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Current versions:"
echo "  Node: $(node --version)"
echo "  npm:  $(npm --version)"
echo "  nvm:  $(nvm --version)"
echo ""
echo "NVM Commands:"
echo "  nvm list                    List installed versions"
echo "  nvm install 20              Install Node 20"
echo "  nvm install --lts           Install latest LTS"
echo "  nvm use 20                  Switch to Node 20"
echo "  nvm alias default 20        Set default version"
echo ""
echo "NPM Commands:"
echo "  npm install -g <pkg>        Install global package"
echo "  npm list -g --depth=0       List global packages"
echo "  npm outdated -g             Check outdated globals"
echo "  npm cache clean --force     Clean cache"
echo ""
HELPER

chmod +x ~/node-helper.sh

echo ""
echo -e "${GREEN}✓${NC} Helper script: ~/node-helper.sh"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC} Restart terminal or run:"
echo "  source ~/.bashrc"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
echo ""