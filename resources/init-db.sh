#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status

echo "--- [PostgreSQL Init] Starting database initialization script ---"

# === Nexus Repository Manager (RM) Database Setup ===
echo "--- [PostgreSQL Init] Setting up Nexus Repository Manager (RM) database and user ---"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create user for Nexus RM
    CREATE USER "${INIT_RM_DB_USER}" WITH PASSWORD '${INIT_APP_DB_PASSWORD}';

    -- Create database for Nexus RM, owned by the RM user
    -- Using en_US.UTF-8 for collate and ctype as per Sonatype's recommendation
    CREATE DATABASE "${INIT_RM_DB_NAME}"
        OWNER "${INIT_RM_DB_USER}"
        ENCODING 'UTF8'
        LC_COLLATE = 'en_US.UTF-8'
        LC_CTYPE = 'en_US.UTF-8'
        TEMPLATE template0;

    -- Grant connect privilege on the RM database to the RM user
    GRANT CONNECT ON DATABASE "${INIT_RM_DB_NAME}" TO "${INIT_RM_DB_USER}";
EOSQL
echo "--- [PostgreSQL Init] Nexus RM User '${INIT_RM_DB_USER}' and Database '${INIT_RM_DB_NAME}' created."

# Connect to the Nexus RM database as the superuser to set schema permissions and extensions
echo "--- [PostgreSQL Init] Configuring schema and extensions for RM Database '${INIT_RM_DB_NAME}' ---"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "${INIT_RM_DB_NAME}" <<-EOSQL
    -- Grant necessary privileges on the public schema to the RM user
    -- This user needs to be able to create tables, sequences, etc.
    GRANT USAGE, CREATE ON SCHEMA public TO "${INIT_RM_DB_USER}";
    GRANT ALL PRIVILEGES ON SCHEMA public TO "${INIT_RM_DB_USER}"; -- More comprehensive

    -- Set default privileges for future objects created by the RM user in the public schema
    -- This ensures the RM user can manage objects it creates
    ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR USER "${INIT_RM_DB_USER}" GRANT ALL ON TABLES TO "${INIT_RM_DB_USER}";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR USER "${INIT_RM_DB_USER}" GRANT ALL ON SEQUENCES TO "${INIT_RM_DB_USER}";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR USER "${INIT_RM_DB_USER}" GRANT ALL ON FUNCTIONS TO "${INIT_RM_DB_USER}";

    -- Install the pg_trgm extension in the public schema, as recommended by Sonatype for Nexus RM
    CREATE EXTENSION IF NOT EXISTS pg_trgm SCHEMA public;
EOSQL
echo "--- [PostgreSQL Init] Schema permissions and pg_trgm extension configured for RM Database '${INIT_RM_DB_NAME}'."


# === Sonatype IQ Server Database Setup ===
echo "--- [PostgreSQL Init] Setting up Sonatype IQ Server database and user ---"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Create user for Sonatype IQ
    CREATE USER "${INIT_IQ_DB_USER}" WITH PASSWORD '${INIT_APP_DB_PASSWORD}';

    -- Create database for Sonatype IQ, owned by the IQ user
    -- Using en_US.UTF-8 for collate and ctype for consistency, adjust if IQ has different requirements
    CREATE DATABASE "${INIT_IQ_DB_NAME}"
        OWNER "${INIT_IQ_DB_USER}"
        ENCODING 'UTF8'
        LC_COLLATE = 'en_US.UTF-8'
        LC_CTYPE = 'en_US.UTF-8'
        TEMPLATE template0;

    -- Grant connect privilege on the IQ database to the IQ user
    GRANT CONNECT ON DATABASE "${INIT_IQ_DB_NAME}" TO "${INIT_IQ_DB_USER}";
EOSQL
echo "--- [PostgreSQL Init] IQ User '${INIT_IQ_DB_USER}' and Database '${INIT_IQ_DB_NAME}' created."

# Connect to the Sonatype IQ database as the superuser to set schema permissions
echo "--- [PostgreSQL Init] Configuring schema for IQ Database '${INIT_IQ_DB_NAME}' ---"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "${INIT_IQ_DB_NAME}" <<-EOSQL
    -- Grant necessary privileges on the public schema to the IQ user
    GRANT USAGE, CREATE ON SCHEMA public TO "${INIT_IQ_DB_USER}";
    GRANT ALL PRIVILEGES ON SCHEMA public TO "${INIT_IQ_DB_USER}"; -- More comprehensive

    -- Set default privileges for future objects created by the IQ user in the public schema
    ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR USER "${INIT_IQ_DB_USER}" GRANT ALL ON TABLES TO "${INIT_IQ_DB_USER}";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR USER "${INIT_IQ_DB_USER}" GRANT ALL ON SEQUENCES TO "${INIT_IQ_DB_USER}";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public FOR USER "${INIT_IQ_DB_USER}" GRANT ALL ON FUNCTIONS TO "${INIT_IQ_DB_USER}";
EOSQL
echo "--- [PostgreSQL Init] Schema permissions configured for IQ Database '${INIT_IQ_DB_NAME}'."

echo "--- [PostgreSQL Init] Database initialization script finished successfully ---"