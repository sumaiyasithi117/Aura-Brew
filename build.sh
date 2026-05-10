#!/usr/bin/env bash
# exit on error
set -o errexit

pip install -r requirements.txt

python manage.py collectstatic --noinput
python manage.py migrate

# অটোমেটেড অ্যাডমিন তৈরির জন্য
python create_admin.py
