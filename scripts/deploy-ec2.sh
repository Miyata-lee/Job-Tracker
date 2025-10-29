#!/bin/bash
# scripts/deploy-ec2.sh 

set -euo pipefail

APP_DIR="/home/ec2-user/jobtracker"
REPO_URL="https://github.com/Miyata-lee/Job-Tracker.git"
BRANCH="${BRANCH:-main}"
VENV_DIR="$APP_DIR/venv"
APP_PORT=5000
SERVICE_NAME="jobtracker"
LOG_FILE="/tmp/jobtracker-ec2-deploy.log"

log(){ echo "[$(date +'%F %T')] $*"; }

trap 'log "Deployment failed at line $LINENO"; exit 1' ERR

log "Stopping existing service if running"
sudo systemctl stop "$SERVICE_NAME" || true

log "Installing OS deps (AL2023)"
if command -v dnf >/dev/null 2>&1; then
  sudo dnf -y update
  sudo dnf -y install python3 python3.11 python3.11-venv git
else
  sudo yum -y update
  sudo yum -y install python3 git
fi

PY_BIN=$(command -v python3.11 || command -v python3)
PIP_BIN="$PY_BIN -m pip"

log "Clone or update repository"
if [ -d "$APP_DIR/.git" ]; then
  git -C "$APP_DIR" fetch origin
  git -C "$APP_DIR" checkout "$BRANCH"
  git -C "$APP_DIR" reset --hard "origin/$BRANCH"
else
  git clone -b "$BRANCH" "$REPO_URL" "$APP_DIR"
fi

log "Create virtual environment"
[ -d "$VENV_DIR" ] || "$PY_BIN" -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

log "Install Python dependencies"
pip install --upgrade pip
pip install -r "$APP_DIR/application/requirements.txt"
pip install gunicorn mysql-connector-python flask-cors

log "Write environment file"
cat > "$APP_DIR/application/.env" <<EOF
DB_HOST=${DB_HOST}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=${DB_NAME}
SECRET_KEY=${SECRET_KEY}
CORS_ORIGINS=${CORS_ORIGINS:-*}
FLASK_ENV=production
EOF
chmod 600 "$APP_DIR/application/.env"

log "Create systemd service"
sudo tee /etc/systemd/system/${SERVICE_NAME}.service >/dev/null <<EOF
[Unit]
Description=JobTracker Flask via Gunicorn
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=${APP_DIR}/application
Environment="PATH=${VENV_DIR}/bin"
Environment="PYTHONUNBUFFERED=1"
ExecStart=${VENV_DIR}/bin/gunicorn --workers 3 --bind 0.0.0.0:${APP_PORT} app:app
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

log "Start service"
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl restart "$SERVICE_NAME"

log "Quick health probe"
sleep 2
curl -fsS "http://127.0.0.1:${APP_PORT}/health" || (journalctl -u "$SERVICE_NAME" -n 200 --no-pager; exit 1)
log "EC2 deployment finished"
