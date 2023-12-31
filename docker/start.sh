#!/usr/bin/env bash
set -e

role=${CONTAINER_ROLE:-app}
env=${APP_ENV:-production}

if [ "$env" != "local" ]; then
  echo "Caching configuration..."
  (cd /code && php artisan config:cache && php artisan route:cache && php artisan view:cache)
fi

if [ "$role" = "app" ]; then
  exec php-fpm
elif [ "$role" = "scheduler" ]; then
  echo "Schedule role"
  while true; do
    php /code/artisan schedule:run --verbose --no-interaction &
    sleep 60
  done
elif [ "$role" = "queue" ]; then
  echo "Running the queue..."
  /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
elif [ "$role" = "npm" ]; then
  echo "Running the npm..."
  yarn &
  yarn run build
else
  echo "Could not match the container role \"$role\""
  exit 1
fi
