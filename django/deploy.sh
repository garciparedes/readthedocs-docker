$PYTHON -m venv venv

source venv/bin/activate

pip install \
  gunicorn \
  setproctitle \
  supervisor


pip install -r requirements.txt
python manage.py migrate

echo \
  "from django.contrib.auth.models import User; \
  User.objects.create_superuser('$ADMIN_USERNAME', '$ADMIN_EMAIL', '$ADMIN_PASSWORD')" | \
  python ./manage.py shell

python manage.py collectstatic --noinput
python manage.py loaddata test_data


supervisord