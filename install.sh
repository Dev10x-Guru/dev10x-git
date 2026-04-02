#!/usr/bin/env sh
# dev10x-git installer — pipe from curl:
#   curl -LsSf https://brave-labs.github.io/dev10x-git/install.sh | sh
#
# Detects your shell and installs functions + tab completions.
# Re-run to update — files are overwritten in place.

set -eu

REPO="https://raw.githubusercontent.com/Brave-Labs/dev10x-git/main"

info()  { printf '\033[0;34m%s\033[0m\n' "$*"; }
ok()    { printf '\033[0;32m%s\033[0m\n' "$*"; }
warn()  { printf '\033[0;33m%s\033[0m\n' "$*"; }
err()   { printf '\033[0;31m%s\033[0m\n' "$*" >&2; }

fetch() {
    if command -v curl >/dev/null 2>&1; then
        curl -LsSf "$1"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- "$1"
    else
        err "error: curl or wget required"
        exit 1
    fi
}

download() {
    local url="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    fetch "$url" > "$dest"
    ok "  installed $dest"
}

install_fish() {
    info "Installing Fish functions and completions..."
    download "$REPO/src/fish/functions/git.fish" \
        "${XDG_CONFIG_HOME:-$HOME/.config}/fish/conf.d/dev10x-git.fish"
    download "$REPO/src/fish/completions/gw.fish" \
        "${XDG_CONFIG_HOME:-$HOME/.config}/fish/completions/gw.fish"
    download "$REPO/src/fish/completions/gwa.fish" \
        "${XDG_CONFIG_HOME:-$HOME/.config}/fish/completions/gwa.fish"
    download "$REPO/src/fish/completions/gwr.fish" \
        "${XDG_CONFIG_HOME:-$HOME/.config}/fish/completions/gwr.fish"
    ok "Fish: open a new tab to activate."
}

install_bash() {
    info "Installing Bash functions and completions..."
    local target="$HOME/.dev10x-git"
    mkdir -p "$target"
    download "$REPO/src/bash/git-utilities.bash" "$target/git-utilities.bash"
    download "$REPO/src/bash/git-completions.bash" "$target/git-completions.bash"

    local rc="$HOME/.bashrc"
    local marker="# dev10x-git"
    if [ -f "$rc" ] && grep -qF "$marker" "$rc"; then
        ok "Bash: source lines already in $rc"
    else
        printf '\n%s\n' "$marker" >> "$rc"
        printf 'source "%s/git-utilities.bash"\n' "$target" >> "$rc"
        printf 'source "%s/git-completions.bash"\n' "$target" >> "$rc"
        ok "Bash: added source lines to $rc — run 'source ~/.bashrc' to activate."
    fi
}

install_zsh() {
    info "Installing Zsh functions and completions..."
    local target="$HOME/.dev10x-git"
    local comp_dir="$HOME/.zsh/completions"
    mkdir -p "$target" "$comp_dir"
    download "$REPO/src/zsh/functions/git-utilities.zsh" "$target/git-utilities.zsh"
    download "$REPO/src/zsh/completions/_gw" "$comp_dir/_gw"
    download "$REPO/src/zsh/completions/_gwa" "$comp_dir/_gwa"
    download "$REPO/src/zsh/completions/_gwr" "$comp_dir/_gwr"

    local rc="$HOME/.zshrc"
    local marker="# dev10x-git"
    if [ -f "$rc" ] && grep -qF "$marker" "$rc"; then
        ok "Zsh: source lines already in $rc"
    else
        printf '\n%s\n' "$marker" >> "$rc"
        printf 'fpath=(~/.zsh/completions $fpath)\n' >> "$rc"
        printf 'source "%s/git-utilities.zsh"\n' "$target" >> "$rc"
        ok "Zsh: added source lines to $rc — run 'exec zsh' to activate."
    fi
}

# ── Main ────────────────────────────────────────────────────────

printf '\n'
info "dev10x-git installer"
info "https://github.com/Brave-Labs/dev10x-git"
printf '\n'

# Detect shell
DETECTED_SHELL=""
case "${SHELL:-}" in
    */fish) DETECTED_SHELL="fish" ;;
    */zsh)  DETECTED_SHELL="zsh"  ;;
    */bash) DETECTED_SHELL="bash" ;;
esac

if [ -n "$DETECTED_SHELL" ]; then
    info "Detected shell: $DETECTED_SHELL"
else
    warn "Could not detect shell from \$SHELL ($SHELL)"
    warn "Installing for all shells..."
fi

case "${1:-$DETECTED_SHELL}" in
    fish)
        install_fish
        ;;
    bash)
        install_bash
        ;;
    zsh)
        install_zsh
        ;;
    all|"")
        # Install for all available shells
        command -v fish >/dev/null 2>&1 && install_fish
        [ -f "$HOME/.bashrc" ] || [ "${SHELL:-}" = */bash ] && install_bash
        [ -f "$HOME/.zshrc" ] || [ "${SHELL:-}" = */zsh ] && install_zsh
        ;;
    *)
        err "Unknown shell: $1"
        err "Usage: install.sh [fish|bash|zsh|all]"
        exit 1
        ;;
esac

printf '\n'
ok "Done! See https://brave-labs.github.io/dev10x-git for docs."
printf '\n'
