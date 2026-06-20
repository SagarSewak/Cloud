#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE auth_db;
    CREATE DATABASE users_db;
    CREATE DATABASE accounts_db;
    CREATE DATABASE trasaction_db;
EOSQL
