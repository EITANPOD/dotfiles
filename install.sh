#!/usr/bin/env bash
# ┌───────────────────────────────────────────────────────────────────────────┐
# │                         Dotfiles Installation Script                       │
# └───────────────────────────────────────────────────────────────────────────┘

set -e

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if running from correct directory
if [[ ! -d "$DOTFILES_DIR" ]]; then
    print_error "Dotfiles directory not found at $DOTFILES_DIR"
    exit 1
fi

cd "$DOTFILES_DIR"

print_header "Eitan's Dotfiles Installer"

# ─────────────────────────────────────────────────────────────────────────────
# Check for Homebrew
# ─────────────────────────────────────────────────────────────────────────────

print_header "Checking Prerequisites"

if ! command -v brew &> /dev/null; then
    print_warning "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    print_success "Homebrew is installed"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Install dependencies from Brewfile
# ─────────────────────────────────────────────────────────────────────────────

print_header "Installing Dependencies"

if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
    print_warning "Installing packages from Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
    print_success "Dependencies installed"
else
    print_warning "No Brewfile found, skipping..."
fi

# ─────────────────────────────────────────────────────────────────────────────
# Backup existing dotfiles
# ─────────────────────────────────────────────────────────────────────────────

print_header "Backing Up Existing Dotfiles"

backup_if_exists() {
    local file="$1"
    if [[ -e "$file" && ! -L "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$file" "$BACKUP_DIR/"
        print_warning "Backed up: $file → $BACKUP_DIR/"
    fi
}

# Files that might need backup
backup_if_exists "$HOME/.zshrc"
backup_if_exists "$HOME/.gitconfig"
backup_if_exists "$HOME/.vimrc"
backup_if_exists "$HOME/.config/tmux"
backup_if_exists "$HOME/.config/starship"
backup_if_exists "$HOME/.config/nvim"
backup_if_exists "$HOME/.config/ghostty"
backup_if_exists "$HOME/.config/fastfetch"

if [[ -d "$BACKUP_DIR" ]]; then
    print_success "Backups saved to: $BACKUP_DIR"
else
    print_success "No existing files needed backup"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Create symlinks with Stow
# ─────────────────────────────────────────────────────────────────────────────

print_header "Creating Symlinks with GNU Stow"

# Ensure .config directory exists
mkdir -p "$HOME/.config"

# Stow each package
PACKAGES=(zsh git vim tmux starship nvim ghostty fastfetch)

for package in "${PACKAGES[@]}"; do
    if [[ -d "$DOTFILES_DIR/$package" ]]; then
        # Remove existing symlinks first to avoid conflicts
        stow -D "$package" 2>/dev/null || true
        stow "$package"
        print_success "Stowed: $package"
    else
        print_warning "Package not found: $package"
    fi
done

# ─────────────────────────────────────────────────────────────────────────────
# Install tmux plugin manager (TPM)
# ─────────────────────────────────────────────────────────────────────────────

print_header "Setting Up Tmux Plugins"

TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    print_success "Installed TPM (Tmux Plugin Manager)"
    print_warning "Run 'prefix + I' in tmux to install plugins"
else
    print_success "TPM already installed"
fi

# Install catppuccin theme for tmux
CATPPUCCIN_DIR="$HOME/.config/tmux/plugins/catppuccin"
if [[ ! -d "$CATPPUCCIN_DIR" ]]; then
    mkdir -p "$HOME/.config/tmux/plugins"
    git clone https://github.com/catppuccin/tmux.git "$CATPPUCCIN_DIR/tmux"
    print_success "Installed Catppuccin theme for tmux"
else
    print_success "Catppuccin tmux theme already installed"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Create local secrets file template
# ─────────────────────────────────────────────────────────────────────────────

print_header "Setting Up Local Configuration"

if [[ ! -f "$HOME/.zshrc.local" ]]; then
    cp "$DOTFILES_DIR/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
    print_success "Created ~/.zshrc.local from template"
    print_warning "Edit ~/.zshrc.local to add your API keys and secrets"
else
    print_success "~/.zshrc.local already exists"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Final message
# ─────────────────────────────────────────────────────────────────────────────

print_header "Installation Complete!"

echo -e "Your dotfiles have been installed successfully.\n"
echo -e "Next steps:"
echo -e "  ${YELLOW}1.${NC} Restart your terminal or run: ${GREEN}source ~/.zshrc${NC}"
echo -e "  ${YELLOW}2.${NC} Edit ${GREEN}~/.zshrc.local${NC} to add your API keys"
echo -e "  ${YELLOW}3.${NC} Open tmux and press ${GREEN}prefix + I${NC} to install plugins"
echo -e "  ${YELLOW}4.${NC} Open nvim and let LazyVim install plugins\n"

echo -e "Useful commands:"
echo -e "  ${GREEN}dotfiles${NC}  - cd to dotfiles directory"
echo -e "  ${GREEN}reload${NC}    - reload zsh configuration\n"
