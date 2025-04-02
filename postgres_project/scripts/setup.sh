#!/bin/bash

# Database setup script
DB_NAME=${1:-"my_database"}
DB_USER=${2:-"my_user"}
DB_PASS=${3:-"my_password"}

# Create database and user
echo "Creating database: $DB_NAME and user: $DB_USER"
psql -U postgres -c "CREATE USER $DB_USER WITH ENCRYPTED PASSWORD '$DB_PASS';"
psql -U postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"

# Apply schema
echo "Applying schema..."
for file in ../schema/*.sql; do
    echo "Applying $(basename "$file")..."
    psql -U "$DB_USER" -d "$DB_NAME" -f "$file"
done

# Apply functions
echo "Applying functions..."
for file in ../functions/*.sql; do
    echo "Applying $(basename "$file")..."
    psql -U "$DB_USER" -d "$DB_NAME" -f "$file"
done

# Apply seeds
echo "Applying seed data..."
for file in ../seeds/*.sql; do
    echo "Applying $(basename "$file")..."
    psql -U "$DB_USER" -d "$DB_NAME" -f "$file"
done

echo "Database setup complete!"

