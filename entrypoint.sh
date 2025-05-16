#!/bin/bash
set -e

# Attendre que la base de données soit prête
echo "Attente de la base de données..."
until PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -c '\q'; do
  echo "Base de données indisponible - attente..."
  sleep 2
done
echo "Base de données disponible !"

# Supprimer un éventuel fichier server.pid
rm -f /app/tmp/pids/server.pid

# Exécuter les migrations de base de données
echo "Exécution des migrations..."
bundle exec rails db:migrate

# Puis exécuter la commande
exec "$@"
