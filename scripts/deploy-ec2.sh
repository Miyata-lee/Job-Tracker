#!/bin/bash
# JobTracker EC2 Flask App Deployment (AL2023-safe)

set -euo pipefail

APP_DIR="/home/ec2-user/jobtracker"
REPO_URL="${REPO_URL:-https://github.com/Miyata-lee/Job-Tracker.git}"
BRANCH="${BRANCH:-main}"
VENV_DIR="$APP_DIR/venv"
APP_PORT=5000
SERVICE_NAME="jobtracker"

log(){ echo "[$(date +'%F %T')] $*"; }

# 1) Stop existing service if present
if sudo systemctl list-unit-files | grep -q "^${SERVICE_NAME}.service"; then
  sudo systemctl stop "$SERVICE_NAME" || true
fi

# 2) OS deps (AL2023 uses dnf)
if command -v dnf >/dev/null 2>&1; then
  sudo dnf -y update
  sudo dnf -y install python3 python3.11 python3.11-venv git
else
  sudo yum -y update
  sudo yum -y install python3 git
fi

PY_BIN=$(command -v python3.11 || command -v python3)

# 3) Clone or update app
if [ -d "$APP_DIR/.git" ]; then
  git -C "$APP_DIR" fetch origin
  git -C "$APP_DIR" checkout "$BRANCH"
  git -C "$APP_DIR" reset --hard "origin/$BRANCH"
else
  git clone -b "$BRANCH" "$REPO_URL" "$APP_DIR"
fi

# 4) Venv + packages
[ -d "$VENV_DIR" ] || "$PY_BIN" -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install -r "$APP_DIR/application/requirements.txt"
pip install gunicorn mysql-connector-python flask-cors

# 5) Write .env for Flask
install -m 600 /dev/null "$APP_DIR/application/.env"
cat > "$APP_DIR/application/.env" <<EOF
DB_HOST=${DB_HOST}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=${DB_NAME}
SECRET_KEY=${SECRET_KEY}
CORS_ORIGINS=${CORS_ORIGINS:-*}
FLASK_ENV=production
EOF

# 6) Create systemd unit
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

# 7) Enable + start
sudo systemctl daemon-reload
sudo systemctl enable --now "$SERVICE_NAME"

# 8) Local health
sleep 2
curl -fsS --connect-timeout 2 --max-time 3 "http://127.0.0.1:${APP_PORT}/health" >/dev/null || {
  sudo journalctl -u "$SERVICE_NAME" -n 200 --no-pager || true
  exit 1
}
log "EC2 app deployed and healthy on ${APP_PORT}"
