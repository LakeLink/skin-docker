#!/bin/sh

echo "Checking database connection"
if ! printf "SELECT 1;\n" | npx prisma db execute --stdin --schema ./prisma/schema.prisma; then
    exit 1
fi

echo "Modifying the prefix in the data table"
db_prefix=""
db_prefix=$(awk -F= '/^DB_PREFIX=/{print substr($0, index($0, "=") + 1); exit}' .env)
escaped_prefix=$(printf '%s' "$db_prefix" | sed 's/[\/&\\]/\\&/g')
for dir in ./dist/prisma ./prisma; do
    [ -d "$dir" ] || continue
    find "$dir" -type f -exec sed -i "s/__PREFIX__/${escaped_prefix}/g" {} +
done

echo "Resolving and deploying database migrations"
npx prisma migrate resolve --applied 0_init
npx prisma migrate deploy

echo "Starting the application"
node dist/main.js
