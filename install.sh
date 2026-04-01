#!/usr/bin/env bash
# ┌───────────────────────────────────────────────────────────────────────────┐
# │                         Dotfiles Installation Script                       │
# │                        Supports: macOS & Fedora Linux                      │
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

# ─────────────────────────────────────────────────────────────────────────────
# OS Detection
# ─────────────────────────────────────────────────────────────────────────────
case "$(uname -s)" in
    Darwin) _OS="macos" ;;
    Linux)  _OS="linux" ;;
    *)      echo "Unsupported OS: $(uname -s)"; exit 1 ;;
esac

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

print_header "Eitan's Dotfiles Installer ($_OS)"

# ─────────────────────────────────────────────────────────────────────────────
# Install Dependencies
# ─────────────────────────────────────────────────────────────────────────────

print_header "Installing Dependencies"

if [[ "$_OS" == "macos" ]]; then
    # ── macOS: Homebrew ──────────────────────────────────────────────────
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

    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        print_warning "Installing packages from Brewfile..."
        brew bundle --file="$DOTFILES_DIR/Brewfile"
        print_success "Brew dependencies installed"
    fi

elif [[ "$_OS" == "linux" ]]; then
    # ── Fedora: DNF ──────────────────────────────────────────────────────
    if ! command -v dnf &> /dev/null; then
        print_error "dnf not found. This script supports Fedora Linux."
        exit 1
    fi

    print_warning "Installing packages via dnf..."

    # Core tools
    sudo dnf install -y \
        stow git neovim tmux zsh \
        zsh-autosuggestions zsh-syntax-highlighting \
        fastfetch htop jq tree

    # Modern CLI replacements
    sudo dnf install -y \
        eza bat ripgrep fd-find zoxide fzf git-delta

    # Development
    sudo dnf install -y \
        python3 nodejs golang

    # yq (not in default Fedora repos)
    if ! command -v yq &> /dev/null; then
        print_warning "Installing yq from GitHub..."
        YQ_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep tag_name | cut -d '"' -f 4)
        sudo curl -L "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" -o /usr/local/bin/yq
        sudo chmod +x /usr/local/bin/yq
    fi

    # Starship prompt
    if ! command -v starship &> /dev/null; then
        print_warning "Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi

    # Infrastructure tools (optional - warn if missing)
    for tool in kubectl helm terraform terragrunt aws az; do
        if ! command -v "$tool" &> /dev/null; then
            print_warning "$tool not found — install manually if needed"
        else
            print_success "$tool is installed"
        fi
    done

    print_success "DNF dependencies installed"
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
backup_if_exists "$HOME/.claude/settings.json"
backup_if_exists "$HOME/.claude/rules"
backup_if_exists "$HOME/.claude/skills"

if [[ -d "$BACKUP_DIR" ]]; then
    print_success "Backups saved to: $BACKUP_DIR"
else
    print_success "No existing files needed backup"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Create symlinks with Stow
# ─────────────────────────────────────────────────────────────────────────────

print_header "Creating Symlinks with GNU Stow"

# Ensure target directories exist
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.claude"

# Stow each package
PACKAGES=(zsh git vim tmux starship nvim ghostty fastfetch claude)

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
# Set default shell to zsh (Linux only)
# ─────────────────────────────────────────────────────────────────────────────

if [[ "$_OS" == "linux" && "$SHELL" != */zsh ]]; then
    print_warning "Setting default shell to zsh..."
    chsh -s "$(command -v zsh)"
    print_success "Default shell set to zsh (takes effect on next login)"
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

if [[ "$_OS" == "linux" ]]; then
    echo -e "  ${YELLOW}Note:${NC} Install infrastructure tools manually if needed:"
    echo -e "    kubectl, helm, terraform, terragrunt, awscli, azure-cli\n"
fi

echo -e "Useful commands:"
echo -e "  ${GREEN}dotfiles${NC}  - cd to dotfiles directory"
echo -e "  ${GREEN}reload${NC}    - reload zsh configuration\n"
