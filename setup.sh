#!/bin/bash

# ===============================
# CONFIGURATION
# ===============================
DB_NAME="dispute_db"
DB_USER="dispute_user"
DB_PASSWORD="dispute_pass"
DB_HOST="localhost"
DB_PORT="5432"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DB_DIR="$SCRIPT_DIR/database"

export PGPASSWORD="$DB_PASSWORD"

echo "======================================="
echo " Smart Dispute & Refund Orchestrator"
echo " Database Setup Script"
echo "======================================="

# ===============================
# CHECK POSTGRES CLIENT
# ===============================
if ! command -v psql >/dev/null 2>&1; then
  echo "❌ psql not found. Please install PostgreSQL client."
  exit 1
fi

# ===============================
# CREATE USER (if not exists)
# ===============================
echo "➡️ Creating DB user (if not exists)..."

psql -h "$DB_HOST" -p "$DB_PORT" -U postgres -tc \
"SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'" | grep -q 1

if [ $? -ne 0 ]; then
  psql -h "$DB_HOST" -p "$DB_PORT" -U postgres <<EOF
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
ALTER USER $DB_USER CREATEDB;
EOF
  echo "✅ User '$DB_USER' created"
else
  echo "ℹ️ User '$DB_USER' already exists"
fi

# ===============================
# CREATE DATABASE (if not exists)
# ===============================
echo "➡️ Creating database (if not exists)..."

psql -h "$DB_HOST" -p "$DB_PORT" -U postgres -tc \
"SELECT 1 FROM pg_database WHERE datname='$DB_NAME'" | grep -q 1

if [ $? -ne 0 ]; then
  psql -h "$DB_HOST" -p "$DB_PORT" -U postgres <<EOF
CREATE DATABASE $DB_NAME OWNER $DB_USER;
EOF
  echo "✅ Database '$DB_NAME' created"
else
  echo "ℹ️ Database '$DB_NAME' already exists"
fi

# ===============================
# RUN SQL SCRIPTS
# ===============================
echo "➡️ Running database scripts..."

psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" <<EOF
\i $DB_DIR/setup_db.sql
\i $DB_DIR/dispute_orchestrator_schema.sql
\i $DB_DIR/seed_dispute_type.sql
\i $DB_DIR/stored_procedures.sql
\i $DB_DIR/seed_db.sql
EOF

if [ $? -ne 0 ]; then
  echo "❌ Database setup failed"
  exit 1
fi

# ===============================
# DONE
# ===============================
echo "======================================="
echo "✅ Database setup completed successfully"
echo "======================================="

# =====================================================
# 3️⃣ BACKEND – BUILD & RUN
# =====================================================

echo "➡️ Building Spring Boot backend..."

cd "$ROOT_DIR/$BACKEND_DIR"
./mvnw clean package -DskipTests

echo "➡️ Starting backend on port $SPRING_PORT..."

nohup ./mvnw spring-boot:run > backend.log 2>&1 &

BACKEND_PID=$!
echo "✅ Backend started (PID=$BACKEND_PID)"

# Wait for backend
sleep 10

# =====================================================
# 4️⃣ FRONTEND – INSTALL & RUN
# =====================================================

echo "➡️ Installing frontend dependencies..."

cd "$ROOT_DIR/$FRONTEND_DIR"
npm install

echo "➡️ Starting Next.js frontend on port $FRONTEND_PORT..."

nohup npm run dev > frontend.log 2>&1 &

FRONTEND_PID=$!
echo "✅ Frontend started (PID=$FRONTEND_PID)"

# =====================================================
# DONE
# =====================================================

echo "=============================================="
echo "🎉 SETUP COMPLETE"
echo "----------------------------------------------"
echo "Backend   : http://localhost:$SPRING_PORT"
echo "Swagger   : http://localhost:$SPRING_PORT/swagger-ui.html"
echo "Frontend  : http://localhost:$FRONTEND_PORT"
echo "DB Health : http://localhost:$SPRING_PORT/health/db"
echo "----------------------------------------------"
echo "Backend log  : backend/backend.log"
echo "Frontend log : frontend/frontend.log"
echo "=============================================="

unset PGPASSWORD