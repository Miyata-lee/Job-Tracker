#!/bin/bash
# File: scripts/deploy-rds.sh
# JobTracker RDS MySQL Deployment Script
# Initializes database schema and tables

set -e

# Configuration
DB_HOST="${DB_HOST}"
DB_USER="${DB_USER}"
DB_PASSWORD="${DB_PASSWORD}"
DB_NAME="jobtracker"
LOG_FILE="/tmp/jobtracker-rds-deploy.log"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
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

log "=========================================="
log "JobTracker RDS MySQL Setup Starting"
log "=========================================="

# Check if mysql client is installed
log "Step 1: Checking mysql client"
if ! command -v mysql &> /dev/null; then
    log "MySQL client not found, installing..."
    sudo yum install -y mysql
    log_success "MySQL client installed"
else
    log_success "MySQL client already installed"
fi

# Validate environment variables
log "Step 2: Validating credentials"
if [ -z "$DB_HOST" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ]; then
    error_exit "Missing database credentials. Please set DB_HOST, DB_USER, DB_PASSWORD environment variables"
fi
log_success "Credentials validated"

# Test RDS connection
log "Step 3: Testing RDS connection"
if mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "SELECT 1" > /dev/null 2>&1; then
    log_success "Connected to RDS: $DB_HOST"
else
    error_exit "Failed to connect to RDS at $DB_HOST. Check credentials and security groups"
fi

# Create database
log "Step 4: Creating database"
mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD << EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
EOF
log_success "Database '$DB_NAME' created or already exists"

# Create tables
log "Step 5: Creating tables"
mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME << 'EOF'

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Jobs table
CREATE TABLE IF NOT EXISTS jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    company_name VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Applied',
    date_applied DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status)
);

EOF
log_success "Tables created"

# Verify tables
log "Step 6: Verifying tables"
TABLES=$(mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "SHOW TABLES;" | wc -l)
log "Tables count: $TABLES"

mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "SHOW TABLES;"
log_success "Database schema verified"

log "=========================================="
log_success "RDS Setup Complete!"
log "=========================================="
log "Database: $DB_NAME"
log "Host: $DB_HOST"
log "User: $DB_USER"
log "Tables: users, jobs"
log "Log file: $LOG_FILE"
log "=========================================="