#!/bin/bash

# Database reset script
DB_NAME=${1:-"my_database"}
DB_USER=${2:-"my_user"}

echo "WARNING: This will reset the database: $DB_NAME!"
read -p "Are you sure you want to continue? (y/n) " -n 1 -r
echo    # move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Drop and recreate database
echo "Dropping database: $DB_NAME"
psql -U postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"
psql -U postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"

# Re-run setup
./setup.sh "$DB_NAME" "$DB_USER"

