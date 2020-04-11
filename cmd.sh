#!/bin/bash
set -e

# Migrate database
echo /opt/apos-backend/manage.py db upgrade

# Start backend with uWSGI
exec uwsgi --ini /etc/uwsgi/apos-backend.ini

