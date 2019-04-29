#!/usr/bin/env bash

set -e

echo "Apply database migrations"
$PYTHON manage.py migrate --settings=${PROJECT_NAME}.settings.docker

echo "Creating admin user"
echo "from django.contrib.auth.models import User; \
  User.objects.create_superuser('$ADMIN_USERNAME', '$ADMIN_EMAIL', '$ADMIN_PASSWORD')" | \
  $PYTHON ./manage.py shell --settings=${PROJECT_NAME}.settings.docker || \
  echo "Admin user already created";

echo "Collect static files"
$PYTHON manage.py collectstatic --noinput --settings=${PROJECT_NAME}.settings.docker

echo "Loading test data"
$PYTHON manage.py loaddata test_data --settings=${PROJECT_NAME}.settings.docker

echo "Running server"
exec "$@"
