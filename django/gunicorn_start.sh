#!/bin/bash
PROJECT_NAME='readthedocs'
DJANGODIR=/www/${PROJECT_NAME}                      # Django project directory
SOCKFILE=/www/${PROJECT_NAME}/run/gunicorn.sock     # We will communicate using this unix socket
USER=root                                           # The user to run as
GROUP=root                                          # The group to run as
NUM_WORKERS=3                                       # How many worker processes should Gunicorn spawn
DJANGO_SETTINGS_MODULE=${PROJECT_NAME}.settings.dev # Which settings file should Django use
DJANGO_WSGI_MODULE=${PROJECT_NAME}.wsgi             # WSGI module name

echo "Starting ${PROJECT_NAME} as `whoami`"

# Activate the virtual environment
cd $DJANGODIR

export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH

# Create the run directory if it doesn't exist
RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec gunicorn ${DJANGO_WSGI_MODULE}:application \
  --name ${PROJECT_NAME} \
  --workers $NUM_WORKERS \
  --user=$USER \
  --group=$GROUP \
  --bind=unix:$SOCKFILE \
  --timeout=300 \
  --log-level=debug \
  --log-file=-
