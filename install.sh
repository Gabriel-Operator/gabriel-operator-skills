#!/usr/bin/env bash
# gabriel-operator gateway skill — curl installer
set -euo pipefail

OWNER="Gabriel-Operator"
REPO="gabriel-operator-skills"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${OWNER}/${REPO}/${BRANCH}"
TARGET_DIR="${1:-.}"

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

log()     { echo -e "${CYAN}  → $*${RESET}"; }
success() { echo -e "${GREEN}  ✓ $*${RESET}"; }
error()   { echo -e "${RED}  ✗ $*${RESET}" >&2; }
header()  { echo -e "\n${BOLD}$*${RESET}"; }

check_node() {
  if ! command -v node &>/dev/null; then
    error "Node.js is required but not found."
    echo "  Install it from https://nodejs.org (v16+) and re-run this script."
    exit 1
  fi
  log "Node.js $(node --version) detected."
}

install_skills() {
  TMP_DIR=$(mktemp -d)
  trap "rm -rf ${TMP_DIR}" EXIT

  log "Downloading CLI from ${RAW_BASE}/cli.js …"

  if command -v curl &>/dev/null; then
    curl -fsSL "${RAW_BASE}/cli.js" -o "${TMP_DIR}/cli.js"
  elif command -v wget &>/dev/null; then
    wget -qO "${TMP_DIR}/cli.js" "${RAW_BASE}/cli.js"
  else
    error "Neither curl nor wget found. Please install one and retry."
    exit 1
  fi

  if command -v curl &>/dev/null; then
    curl -fsSL "${RAW_BASE}/package.json" -o "${TMP_DIR}/package.json" 2>/dev/null || true
  fi

  success "CLI downloaded."
  log "Installing Gabriel Operator skill into ${TARGET_DIR} …"
  echo ""

  node "${TMP_DIR}/cli.js" add "${TARGET_DIR}"
}

header "🔧 Gabriel Operator gateway skill installer"
check_node
install_skills
