#!/bin/bash
# File: scripts/deploy-ec2.sh
# JobTracker EC2 Flask App Deployment Script

set -e

APP_DIR="/home/ec2-user/jobtracker"
REPO_URL="https://github.com/Miyata-lee/Job-Tracker.git"
BRANCH="${BRANCH:-main}"
VENV_DIR="$APP_DIR/venv"
APP_PORT=5000
SERVICE_NAME="jobtracker"
LOG_FILE="/tmp/jobtracker-ec2-deploy.log"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a $LOG_FILE
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✓ $1${NC}" | tee -a $LOG_FILE
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ✗ $1${NC}" | tee -a $LOG_FILE
}

error_exit() {
    log_error "$1"
    exit 1
}

trap 'error_exit "Deployment failed at line $LINENO"' ERR

log "=========================================="
log "JobTracker EC2 Deployment Starting"
log "=========================================="

log "Step 1: Stopping service"
if sudo systemctl is-active --quiet $SERVICE_NAME; then
    sudo systemctl stop $SERVICE_NAME
    log_success "Service stopped"
else
    log "Service not running"
fi

log "Step 2: Installing dependencies"
sudo yum update -y
sudo yum install -y python3 python3-pip python3-venv git

log "Step 3: Repository management"
if [ -d "$APP_DIR" ]; then
    log "Updating existing repository..."
    cd $APP_DIR
    git fetch origin
    git checkout $BRANCH
    git reset --hard origin/$BRANCH
    log_success "Repository updated"
else
    log "Cloning repository..."
    git clone -b $BRANCH $REPO_URL $APP_DIR
    cd $APP_DIR
    log_success "Repository cloned"
fi

log "Step 4: Setting up virtual environment"
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv $VENV_DIR
    log_success "Virtual environment created"
fi

log "Step 5: Installing Python packages"
source $VENV_DIR/bin/activate
pip install --upgrade pip --quiet
pip install -r application/requirements.txt --quiet
pip install gunicorn --quiet
log_success "Python packages installed"

log "Step 6: Creating environment configuration"
cat > $APP_DIR/application/.env << EOF
DB_HOST=$DB_HOST
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_NAME=$DB_NAME
SECRET_KEY=$SECRET_KEY
FLASK_ENV=production
FLASK_APP=app:app
EOF
chmod 600 $APP_DIR/application/.env
log_success "Environment file created"

log "Step 7: Creating systemd service"
sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null << EOF
[Unit]
Description=JobTracker Flask Application
After=network.target

[Service]
Type=notify
User=ec2-user
WorkingDirectory=$APP_DIR/application
Environment="PATH=$VENV_DIR/bin"
Environment="PYTHONUNBUFFERED=1"
ExecStart=$VENV_DIR/bin/gunicorn \
    --workers 4 \
    --worker-class sync \
    --bind 0.0.0.0:$APP_PORT \
    --timeout 30 \
    --access-logfile - \
    --error-logfile - \
    app:app
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
log_success "Systemd service created"

log "Step 8: Starting service"
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME
sleep 2

if sudo systemctl is-active --quiet $SERVICE_NAME; then
    log_success "Service started"
else
    error_exit "Service failed to start"
fi

log "Step 9: Health check"
for i in {1..30}; do
    if curl -f http://localhost:$APP_PORT/health 2>/dev/null || curl -f http://localhost:$APP_PORT 2>/dev/null; then
        log_success "Application is responding"
        break
    fi
    if [ $i -eq 30 ]; then
        error_exit "Application health check failed"
    fi
    sleep 2
done

log "=========================================="
log_success "EC2 Deployment Complete!"
log "=========================================="
log "Service: $SERVICE_NAME"
log "Running on: http://localhost:$APP_PORT"
log "Branch: $BRANCH"
log "=========================================="