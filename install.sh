#!/usr/bin/env bash
# ==============================================================================
# yazi-dolphin: Full GUI File Manager Replacement Suite
# Installer & System Integrator
# ==============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config/yazi"
BIN_DIR="${HOME}/.local/bin"
MIME_FILE="${HOME}/.config/mimeapps.list"
DESKTOP_DIR="${HOME}/.local/share/applications"

BOLD="\033[1m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RED="\033[1;31m"
RESET="\033[0m"

print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "  ╔═══════════════════════════════════════════════════════════════╗"
    echo "  ║                   YAZI DOLPHIN DROP-IN SUITE                  ║"
    echo "  ║        Terminal File Manager with Complete GUI Parity        ║"
    echo "  ╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

usage() {
    echo "Usage: ./install.sh [OPTION]"
    echo ""
    echo "Options:"
    echo "  --install        Install configs, register MIME handlers & link binary (default)"
    echo "  --status         Verify dependencies, symlinks, and desktop registration"
    echo "  --uninstall      Restore original configuration and remove symlinks"
    echo "  --help           Show this help message"
    echo ""
}

check_tool() {
    local cmd="$1"
    local desc="$2"
    if command -v "${cmd}" &>/dev/null; then
        echo -e "  ${GREEN}✔${RESET} ${BOLD}${cmd}${RESET} - ${desc}"
    else
        echo -e "  ${YELLOW}⚠${RESET} ${BOLD}${cmd}${RESET} - ${desc} (${RED}missing${RESET})"
    fi
}

check_dependencies() {
    echo -e "\n${CYAN}▶ Checking System Dependencies...${RESET}"
    check_tool "yazi" "Core terminal file manager"
    check_tool "ouch" "Universal archive preview & multi-destination extraction"
    check_tool "fzf" "Fuzzy interactive searching & zoxide jump picker"
    check_tool "rg" "Ripgrep file content searching"
    check_tool "zoxide" "Smart directory history and jumping"
    check_tool "imv" "Wayland-native lightning fast image viewer"
    check_tool "glow" "Terminal Markdown visualizer"
    check_tool "bat" "Syntax-highlighted code and text viewer"
    check_tool "mpv" "Media (audio/video) background and modal player"
    check_tool "kdialog" "GUI directory selection dialog fallback"
    check_tool "micro" "Intuitive modern terminal text editor (nano replacement)"
}

install_suite() {
    print_banner
    check_dependencies

    echo -e "\n${CYAN}▶ Installing Yazi Configuration...${RESET}"
    mkdir -p "${HOME}/.config" "${BIN_DIR}" "${DESKTOP_DIR}"

    if [[ -d "${CONFIG_DIR}" ]] && [[ ! -L "${CONFIG_DIR}" ]]; then
        local backup="${CONFIG_DIR}.bak.$(date +%Y%m%d%H%M%S)"
        echo -e "  ${YELLOW}Backing up existing ${CONFIG_DIR} to ${backup}${RESET}"
        mv "${CONFIG_DIR}" "${backup}"
    fi

    # Symlink entire config directory
    echo -e "  Linking ${REPO_DIR}/config -> ${CONFIG_DIR}"
    ln -sfn "${REPO_DIR}/config" "${CONFIG_DIR}"

    # Symlink binaries
    echo -e "  Linking ${REPO_DIR}/bin/yazi-dolphin -> ${BIN_DIR}/yazi-dolphin"
    ln -sfn "${REPO_DIR}/bin/yazi-dolphin" "${BIN_DIR}/yazi-dolphin"
    echo -e "  Linking ${REPO_DIR}/bin/glow-pager -> ${BIN_DIR}/glow-pager"
    ln -sfn "${REPO_DIR}/bin/glow-pager" "${BIN_DIR}/glow-pager"

    echo -e "\n${CYAN}▶ Registering Desktop & MIME Handlers...${RESET}"
    if [[ -f "${REPO_DIR}/system/yazi.desktop" ]]; then
        cp "${REPO_DIR}/system/yazi.desktop" "${DESKTOP_DIR}/yazi.desktop"
        echo -e "  ${GREEN}✔${RESET} Installed ${DESKTOP_DIR}/yazi.desktop"
    fi

    if [[ -f "${MIME_FILE}" ]]; then
        if grep -q "inode/directory=" "${MIME_FILE}"; then
            sed -i 's|^inode/directory=.*|inode/directory=yazi.desktop;|g' "${MIME_FILE}"
        else
            sed -i '/\[Default Applications\]/a inode/directory=yazi.desktop;' "${MIME_FILE}"
        fi
        echo -e "  ${GREEN}✔${RESET} Registered yazi.desktop as default inode/directory in ${MIME_FILE}"
    fi

    # Seed zoxide database if empty
    if command -v zoxide &>/dev/null; then
        zoxide add "${HOME}" "${HOME}/Downloads" "${HOME}/Documents" "${HOME}/Pictures" "${HOME}/Videos" 2>/dev/null || true
    fi

    echo -e "\n${GREEN}${BOLD}✔ Yazi Dolphin Drop-In Suite successfully installed!${RESET}"
    echo -e "Launch Yazi using ${BOLD}yazi${RESET} or ${BOLD}yazi-dolphin${RESET}."
}

show_status() {
    print_banner
    check_dependencies

    echo -e "\n${CYAN}▶ Checking Installation Status...${RESET}"
    if [[ -L "${CONFIG_DIR}" ]] && [[ "$(readlink "${CONFIG_DIR}")" == "${REPO_DIR}/config" ]]; then
        echo -e "  ${GREEN}✔${RESET} Config symlink: ${CONFIG_DIR} -> $(readlink "${CONFIG_DIR}")"
    else
        echo -e "  ${YELLOW}⚠${RESET} Config symlink: ${CONFIG_DIR} does not point to this repository."
    fi

    if [[ -L "${BIN_DIR}/yazi-dolphin" ]]; then
        echo -e "  ${GREEN}✔${RESET} Launcher symlink: ${BIN_DIR}/yazi-dolphin -> $(readlink "${BIN_DIR}/yazi-dolphin")"
    else
        echo -e "  ${YELLOW}⚠${RESET} Launcher symlink missing in ${BIN_DIR}."
    fi

    if [[ -f "${MIME_FILE}" ]] && grep -q "inode/directory=yazi.desktop" "${MIME_FILE}"; then
        echo -e "  ${GREEN}✔${RESET} System default file manager: yazi.desktop"
    else
        echo -e "  ${YELLOW}⚠${RESET} inode/directory in ${MIME_FILE} is not set to yazi.desktop."
    fi
}

uninstall_suite() {
    echo -e "${YELLOW}▶ Uninstalling Yazi Dolphin Drop-In Suite...${RESET}"
    rm -f "${BIN_DIR}/yazi-dolphin" "${BIN_DIR}/glow-pager"
    if [[ -L "${CONFIG_DIR}" ]] && [[ "$(readlink "${CONFIG_DIR}")" == "${REPO_DIR}/config" ]]; then
        rm -f "${CONFIG_DIR}"
        echo -e "  Removed ${CONFIG_DIR} symlink."
    fi
    echo -e "${GREEN}✔ Uninstallation complete.${RESET}"
}

ACTION="${1:---install}"

case "${ACTION}" in
    --install)
        install_suite
        ;;
    --status)
        show_status
        ;;
    --uninstall)
        uninstall_suite
        ;;
    --help|-h)
        usage
        ;;
    *)
        echo -e "${RED}Unknown option: ${ACTION}${RESET}"
        usage
        exit 1
        ;;
esac
