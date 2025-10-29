#!/usr/bin/env bash
# JobTracker RDS MySQL Schema Initialization

set -euo pipefail

DB_HOST="${DB_HOST:?missing}"
DB_USER="${DB_USER:?missing}"
DB_PASSWORD="${DB_PASSWORD:?missing}"
DB_NAME="${DB_NAME:-jobtracker}"

log(){ echo "[$(date +'%F %T')] $*"; }

# Install MySQL client
if ! command -v mysql >/dev/null 2>&1; then
  sudo dnf -y install mysql || sudo yum -y install mysql
fi

# Test connection
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" >/dev/null

# Create DB
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
EOF

# Tables
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" <<'EOF'
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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

log "RDS schema ready in ${DB_NAME}"
#!/usr/bin/env bash
# JobTracker RDS MySQL Schema Initialization

set -euo pipefail

DB_HOST="${DB_HOST:?missing}"
DB_USER="${DB_USER:?missing}"
DB_PASSWORD="${DB_PASSWORD:?missing}"
DB_NAME="${DB_NAME:-jobtracker}"

log(){ echo "[$(date +'%F %T')] $*"; }

# Install MySQL client
if ! command -v mysql >/dev/null 2>&1; then
  sudo dnf -y install mysql || sudo yum -y install mysql
fi

# Test connection
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" >/dev/null

# Create DB
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
EOF

# Tables
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" <<'EOF'
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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

log "RDS schema ready in ${DB_NAME}"
