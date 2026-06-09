#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#   ʏᴜᴋɪ ʏᴛ ᴀᴘɪ — ᴀᴜᴛᴏ ɪɴꜱᴛᴀʟʟᴇʀ
#   © 2026 ᴋᴀɪᴛᴏ | ʜᴇʟʟꜰɪʀᴇᴅᴇᴠꜱ
#   Usage: curl -fsSL https://yourdomain.com/install | bash
# ═══════════════════════════════════════════════════════════════

set -e

# ── Colors ────────────────────────────────────────────────────
RED='\033[0;31m';  GRN='\033[0;32m'; YLW='\033[1;33m'
CYN='\033[0;36m';  MAG='\033[0;35m'; BLD='\033[1m'; RST='\033[0m'

info()    { echo -e "${CYN}  ❯${RST} $1"; }
success() { echo -e "${GRN}  ✔${RST} $1"; }
warn()    { echo -e "${YLW}  ⚠${RST} $1"; }
error()   { echo -e "${RED}  ✘${RST} $1"; exit 1; }
section() { echo -e "\n${BLD}${MAG}── $1 ${RST}"; }
ask()     { echo -ne "${YLW}  ?${RST} $1 "; }

banner() {
    echo -e "${CYN}"
    echo '  ██╗   ██╗██╗   ██╗██╗  ██╗██╗    ██╗   ██╗████████╗     █████╗ ██████╗ ██╗'
    echo '  ╚██╗ ██╔╝██║   ██║██║ ██╔╝██║    ╚██╗ ██╔╝╚══██╔══╝    ██╔══██╗██╔══██╗██║'
    echo '   ╚████╔╝ ██║   ██║█████╔╝ ██║     ╚████╔╝    ██║       ███████║██████╔╝██║'
    echo '    ╚██╔╝  ██║   ██║██╔═██╗ ██║      ╚██╔╝     ██║       ██╔══██║██╔═══╝ ██║'
    echo '     ██║   ╚██████╔╝██║  ██╗██║       ██║       ██║       ██║  ██║██║     ██║'
    echo '     ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝       ╚═╝       ╚═╝       ╚═╝  ╚═╝╚═╝     ╚═╝'
    echo -e "${RST}"
    echo -e "  ${BLD}YUKI YT API — Auto Installer${RST}  |  ${CYN}© 2026 HellfireDevs${RST}"
    echo -e "  ─────────────────────────────────────────────────────\n"
}

# ── Root check ────────────────────────────────────────────────
check_root() {
    [ "$EUID" -ne 0 ] && error "Root required. Run with: sudo bash"
}

# ── OS check ──────────────────────────────────────────────────
check_os() {
    if ! grep -qi "ubuntu\|debian" /etc/os-release 2>/dev/null; then
        warn "Tested on Ubuntu/Debian only. Proceeding anyway..."
    fi
    success "OS check passed"
}

# ── Config prompts ────────────────────────────────────────────
collect_config() {
    section "Configuration"

    ask "GitHub repo URL (e.g. https://github.com/user/YUKIYTAPI):"
    read -r REPO_URL
    [ -z "$REPO_URL" ] && error "Repo URL required."

    ask "Install directory [/opt/yukiytapi]:"
    read -r INSTALL_DIR
    INSTALL_DIR="${INSTALL_DIR:-/opt/yukiytapi}"

    ask "Port [8000]:"
    read -r API_PORT
    API_PORT="${API_PORT:-8000}"

    ask "Use Cloudflare Tunnel for public URL? [Y/n]:"
    read -r USE_CF
    USE_CF="${USE_CF:-Y}"

    echo ""
    info "Config:"
    echo -e "   Repo       : ${BLD}$REPO_URL${RST}"
    echo -e "   Directory  : ${BLD}$INSTALL_DIR${RST}"
    echo -e "   Port       : ${BLD}$API_PORT${RST}"
    echo -e "   Cloudflare : ${BLD}$( [[ "$USE_CF" =~ ^[Yy]$ ]] && echo "Yes (temp tunnel)" || echo "No (localhost only)" )${RST}"
    echo ""
    ask "Proceed? [Y/n]:"
    read -r CONFIRM
    [[ "$CONFIRM" =~ ^[Nn]$ ]] && error "Aborted."
}

# ── System deps ───────────────────────────────────────────────
install_system_deps() {
    section "System Dependencies"
    info "Updating apt..."
    apt-get update -qq

    info "Installing base packages..."
    apt-get install -y -qq \
        curl wget git build-essential tmux \
        software-properties-common ca-certificates \
        ffmpeg python3-pip python3-venv python3-dev \
        > /dev/null 2>&1
    success "System packages installed"
}

# ── Python — auto detect best version ────────────────────────
PYTHON_BIN=""

install_python() {
    section "Python (3.10+)"

    # Find best already-installed version (prefer highest)
    for ver in 3.13 3.12 3.11 3.10; do
        if command -v "python${ver}" &>/dev/null; then
            PYTHON_BIN="python${ver}"
            success "Found $PYTHON_BIN ($(${PYTHON_BIN} --version 2>&1))"
            return
        fi
    done

    # Fallback: check generic python3
    if command -v python3 &>/dev/null; then
        PY_MINOR=$(python3 -c "import sys; print(sys.version_info.minor)")
        PY_MAJOR=$(python3 -c "import sys; print(sys.version_info.major)")
        if [ "$PY_MAJOR" -ge 3 ] && [ "$PY_MINOR" -ge 10 ]; then
            PYTHON_BIN="python3"
            success "python3 is $(python3 --version) — OK"
            return
        fi
    fi

    # Install 3.11 via deadsnakes
    warn "No Python 3.10+ found — installing 3.11 via deadsnakes PPA..."
    apt-get install -y -qq software-properties-common > /dev/null 2>&1
    add-apt-repository -y ppa:deadsnakes/ppa > /dev/null 2>&1
    apt-get update -qq
    apt-get install -y -qq python3.11 python3.11-venv python3.11-dev > /dev/null 2>&1
    PYTHON_BIN="python3.11"
    success "Python 3.11 installed via deadsnakes"
}

# ── Fix PEP 668 (Ubuntu 22.04+ blocks global pip) ────────────
fix_pip() {
    section "pip PEP 668 Fix"

    PY_VER_SHORT=$($PYTHON_BIN -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    MANAGED_FILE="/usr/lib/python${PY_VER_SHORT}/EXTERNALLY-MANAGED"

    if [ -f "$MANAGED_FILE" ]; then
        rm -f "$MANAGED_FILE"
        success "Removed EXTERNALLY-MANAGED for Python $PY_VER_SHORT"
    else
        success "No PEP 668 restriction — all good"
    fi

    $PYTHON_BIN -m pip install --upgrade pip -q 2>/dev/null || true
    success "pip ready"
}

# ── Node.js (yt-dlp needs it) ─────────────────────────────────
install_node() {
    section "Node.js (for yt-dlp)"
    if command -v node &>/dev/null; then
        success "Node.js $(node --version) already installed"
        return
    fi
    info "Installing Node.js 20 LTS..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - > /dev/null 2>&1
    apt-get install -y -qq nodejs > /dev/null 2>&1
    success "Node.js $(node --version) installed"
}

# ── Clone repo ────────────────────────────────────────────────
clone_repo() {
    section "Cloning Repository"
    if [ -d "$INSTALL_DIR/.git" ]; then
        warn "$INSTALL_DIR exists — pulling latest..."
        git -C "$INSTALL_DIR" pull > /dev/null 2>&1
    else
        info "Cloning → $INSTALL_DIR"
        git clone "$REPO_URL" "$INSTALL_DIR" > /dev/null 2>&1
    fi
    success "Repo ready"
}

# ── Venv + pip deps ───────────────────────────────────────────
setup_venv() {
    section "Virtual Environment"
    cd "$INSTALL_DIR"

    if [ ! -d "venv" ]; then
        info "Creating venv with $PYTHON_BIN..."
        $PYTHON_BIN -m venv venv
    else
        info "venv exists — reusing"
    fi

    source venv/bin/activate
    pip install -q --upgrade pip

    if [ -f "requirements.txt" ]; then
        pip install -q -r requirements.txt
    else
        warn "requirements.txt not found — installing defaults..."
        pip install -q fastapi uvicorn yt-dlp pymongo aiofiles
    fi

    pip install -q --upgrade yt-dlp   # always latest
    deactivate
    success "Venv ready (Python: $($INSTALL_DIR/venv/bin/python --version))"
}

# ── .env ──────────────────────────────────────────────────────
setup_env() {
    section "Environment Config"
    cd "$INSTALL_DIR"
    mkdir -p logs

    if [ ! -f ".env" ]; then
        cat > .env <<EOF
API_PORT=${API_PORT}
EOF
        success ".env created"
    else
        warn ".env exists — skipping"
    fi
}

# ── tmux session (API) ────────────────────────────────────────
setup_tmux() {
    section "API — tmux Session"
    cd "$INSTALL_DIR"

    tmux kill-session -t yukiytapi 2>/dev/null || true

    tmux new-session -d -s yukiytapi \
        "cd ${INSTALL_DIR} && source venv/bin/activate && \
        PYTHONPATH=${INSTALL_DIR} uvicorn YUKIYTAPI.main:app \
        --host 0.0.0.0 --port ${API_PORT} 2>&1 | tee logs/api.log"

    success "tmux session 'yukiytapi' started"

    # systemd for auto-restart on reboot
    cat > /etc/systemd/system/yukiytapi.service <<EOF
[Unit]
Description=YUKI YT API
After=network.target

[Service]
Type=forking
User=root
WorkingDirectory=${INSTALL_DIR}
ExecStart=/usr/bin/tmux new-session -d -s yukiytapi \
    "cd ${INSTALL_DIR} && source venv/bin/activate && \
    PYTHONPATH=${INSTALL_DIR} uvicorn YUKIYTAPI.main:app \
    --host 0.0.0.0 --port ${API_PORT} 2>&1 | tee logs/api.log"
ExecStop=/usr/bin/tmux kill-session -t yukiytapi
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable yukiytapi > /dev/null 2>&1
    success "systemd service enabled (auto-start on reboot)"
}

# ── Cloudflare Tunnel ─────────────────────────────────────────
CF_URL=""

setup_cloudflare() {
    [[ ! "$USE_CF" =~ ^[Yy]$ ]] && return

    section "Cloudflare Tunnel"

    # Install cloudflared if needed
    if ! command -v cloudflared &>/dev/null; then
        info "Downloading cloudflared..."
        ARCH=$(uname -m)
        case "$ARCH" in
            x86_64)  CF_ARCH="amd64" ;;
            aarch64) CF_ARCH="arm64" ;;
            armv7l)  CF_ARCH="arm"   ;;
            *)       CF_ARCH="amd64" ;;
        esac
        curl -fsSL "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CF_ARCH}" \
            -o /usr/local/bin/cloudflared
        chmod +x /usr/local/bin/cloudflared
        success "cloudflared installed"
    else
        success "cloudflared already installed"
    fi

    # Kill old CF session if exists
    tmux kill-session -t yukiytapi-cf 2>/dev/null || true

    # Start tunnel in separate tmux session, log to file
    CF_LOG="${INSTALL_DIR}/logs/cloudflare.log"
    tmux new-session -d -s yukiytapi-cf \
        "cloudflared tunnel --url http://localhost:${API_PORT} 2>&1 | tee ${CF_LOG}"

    success "Cloudflare Tunnel started in tmux session 'yukiytapi-cf'"

    # Wait and extract URL from log
    info "Waiting for tunnel URL..."
    for i in $(seq 1 15); do
        sleep 2
        CF_URL=$(grep -oP 'https://[a-zA-Z0-9\-]+\.trycloudflare\.com' "$CF_LOG" 2>/dev/null | head -1)
        [ -n "$CF_URL" ] && break
        echo -ne "  ${CYN}  Waiting... (${i}/15)\r${RST}"
    done
    echo ""

    if [ -n "$CF_URL" ]; then
        success "Tunnel URL: ${BLD}${CF_URL}${RST}"
    else
        warn "URL not detected yet — check: tmux attach -t yukiytapi-cf"
    fi
}

# ── Firewall ──────────────────────────────────────────────────
setup_firewall() {
    section "Firewall"
    if command -v ufw &>/dev/null; then
        ufw allow 22/tcp          > /dev/null 2>&1
        ufw allow "$API_PORT/tcp" > /dev/null 2>&1
        ufw --force enable        > /dev/null 2>&1
        success "UFW rules set"
    else
        warn "UFW not found — skipping"
    fi
}

# ── ytapi CLI ─────────────────────────────────────────────────
install_cli() {
    section "ytapi CLI"

    cat > /usr/local/bin/ytapi << EOF
#!/bin/bash
# ── ytapi — YUKI YT API manager ──────────────────────────────
RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'
CYN='\033[0;36m'; BLD='\033[1m'; RST='\033[0m'

INSTALL_DIR="${INSTALL_DIR}"
API_PORT="${API_PORT}"

_die()  { echo -e "\${RED}  ✘\${RST} \$1"; exit 1; }
_ok()   { echo -e "\${GRN}  ✔\${RST} \$1"; }
_info() { echo -e "\${CYN}  ❯\${RST} \$1"; }

case "\$1" in

  start)
    _info "Starting YUKI YT API..."
    tmux kill-session -t yukiytapi 2>/dev/null || true
    tmux new-session -d -s yukiytapi \
      "cd \${INSTALL_DIR} && source venv/bin/activate && \
      PYTHONPATH=\${INSTALL_DIR} uvicorn YUKIYTAPI.main:app \
      --host 0.0.0.0 --port \${API_PORT} 2>&1 | tee logs/api.log"
    _ok "Started — tmux session: yukiytapi"
    ;;

  stop)
    _info "Stopping..."
    tmux kill-session -t yukiytapi    2>/dev/null && _ok "API stopped"    || true
    tmux kill-session -t yukiytapi-cf 2>/dev/null && _ok "CF tunnel stopped" || true
    ;;

  restart)
    \$0 stop
    sleep 1
    \$0 start
    ;;

  status)
    echo -e "\n\${BLD}── YUKI YT API Status ──\${RST}"
    tmux has-session -t yukiytapi    2>/dev/null \
      && echo -e "  API      : \${GRN}Running\${RST}" \
      || echo -e "  API      : \${RED}Stopped\${RST}"
    tmux has-session -t yukiytapi-cf 2>/dev/null \
      && echo -e "  Tunnel   : \${GRN}Running\${RST}" \
      || echo -e "  Tunnel   : \${YLW}Not running\${RST}"
    systemctl is-active --quiet yukiytapi \
      && echo -e "  Systemd  : \${GRN}Enabled\${RST}" \
      || echo -e "  Systemd  : \${YLW}Disabled\${RST}"
    echo ""
    curl -s http://localhost:\${API_PORT}/ 2>/dev/null \
      && echo "" || echo -e "  \${RED}API not responding on port \${API_PORT}\${RST}"
    ;;

  logs)
    _info "Press Ctrl+C to exit"
    tail -f "\${INSTALL_DIR}/logs/api.log"
    ;;

  attach)
    tmux attach -t yukiytapi 2>/dev/null || _die "Session not running. Use: ytapi start"
    ;;

  tunnel)
    tmux attach -t yukiytapi-cf 2>/dev/null || _die "Tunnel not running."
    ;;

  update)
    _info "Pulling latest code..."
    cd "\${INSTALL_DIR}" && git pull
    _info "Updating pip deps..."
    source venv/bin/activate && pip install -q --upgrade yt-dlp
    [ -f requirements.txt ] && pip install -q -r requirements.txt
    deactivate
    _ok "Updated. Restarting..."
    \$0 restart
    ;;

  uninstall)
    echo -e "\${YLW}  ⚠  This will remove YUKI YT API completely.\${RST}"
    echo -ne "\${YLW}  ?  Sure? [y/N]:\${RST} "
    read -r CONFIRM
    [[ ! "\$CONFIRM" =~ ^[Yy]$ ]] && echo "Aborted." && exit 0

    _info "Stopping services..."
    tmux kill-session -t yukiytapi    2>/dev/null || true
    tmux kill-session -t yukiytapi-cf 2>/dev/null || true
    systemctl stop    yukiytapi 2>/dev/null || true
    systemctl disable yukiytapi 2>/dev/null || true

    _info "Removing files..."
    rm -f /etc/systemd/system/yukiytapi.service
    systemctl daemon-reload
    rm -rf "\${INSTALL_DIR}"
    rm -f /usr/local/bin/cloudflared
    rm -f /usr/local/bin/ytapi

    ufw delete allow "\${API_PORT}/tcp" 2>/dev/null || true

    _ok "YUKI YT API uninstalled completely."
    ;;

  *)
    echo -e "\n\${BLD}ytapi\${RST} — YUKI YT API Manager\n"
    echo -e "  \${CYN}ytapi start\${RST}      — Start API"
    echo -e "  \${CYN}ytapi stop\${RST}       — Stop API + tunnel"
    echo -e "  \${CYN}ytapi restart\${RST}    — Restart"
    echo -e "  \${CYN}ytapi status\${RST}     — Status check"
    echo -e "  \${CYN}ytapi logs\${RST}       — Live log tail"
    echo -e "  \${CYN}ytapi attach\${RST}     — Attach API tmux session"
    echo -e "  \${CYN}ytapi tunnel\${RST}     — Attach CF tunnel session"
    echo -e "  \${CYN}ytapi update\${RST}     — Pull + restart"
    echo -e "  \${CYN}ytapi uninstall\${RST}  — Remove everything"
    echo ""
    ;;
esac
EOF

    chmod +x /usr/local/bin/ytapi
    success "ytapi CLI installed → /usr/local/bin/ytapi"
}

# ── Summary ───────────────────────────────────────────────────
print_summary() {
    echo ""
    echo -e "${GRN}═══════════════════════════════════════════════════${RST}"
    echo -e "${BLD}${GRN}  ✔  YUKI YT API — Installation Complete!${RST}"
    echo -e "${GRN}═══════════════════════════════════════════════════${RST}"
    echo ""
    echo -e "  ${BLD}Local URL   :${RST} http://localhost:${API_PORT}"
    [ -n "$CF_URL" ] && \
    echo -e "  ${BLD}Public URL  :${RST} ${CYN}${CF_URL}${RST}"
    echo -e "  ${BLD}Install Dir :${RST} ${INSTALL_DIR}"
    echo -e "  ${BLD}Python      :${RST} $($INSTALL_DIR/venv/bin/python --version 2>&1)"
    echo ""
    echo -e "  ${BLD}ytapi commands:${RST}"
    echo -e "    ${CYN}ytapi start${RST}      — Start"
    echo -e "    ${CYN}ytapi stop${RST}       — Stop"
    echo -e "    ${CYN}ytapi restart${RST}    — Restart"
    echo -e "    ${CYN}ytapi status${RST}     — Status"
    echo -e "    ${CYN}ytapi logs${RST}       — Live logs"
    echo -e "    ${CYN}ytapi update${RST}     — Pull + restart"
    echo -e "    ${CYN}ytapi uninstall${RST}  — Remove everything"
    echo ""
    echo -e "${GRN}═══════════════════════════════════════════════════${RST}"
    echo ""
}

# ── Main ──────────────────────────────────────────────────────
main() {
    clear
    banner
    check_root
    check_os
    collect_config
    install_system_deps
    install_python
    fix_pip
    install_node
    clone_repo
    setup_venv
    setup_env
    setup_tmux
    setup_cloudflare
    setup_firewall
    install_cli
    print_summary
}

main "$@"
