-- login as postgres user
CREATE DATABASE dispute_db;

CREATE USER dispute_user WITH PASSWORD 'dispute_pass';

GRANT ALL PRIVILEGES ON DATABASE dispute_db TO dispute_user;
GRANT USAGE, CREATE ON SCHEMA public TO dispute_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO dispute_user;
