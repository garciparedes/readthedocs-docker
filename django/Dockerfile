FROM python:3.6

# Environment Variables

ARG SVN_USERNAME
ARG SVN_PASSWORD
ARG ADMIN_USERNAME
ARG ADMIN_EMAIL
ARG ADMIN_PASSWORD

ENV PORT=8000 \
    DOMAIN=0.0.0.0 \
    DEBIAN_FRONTEND=noninteractive \
    PYTHON=python3.6

# Package Installation

RUN apt-get update -y
RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get -y install \
      software-properties-common \
      vim

RUN apt-get install -y \
  build-essential \
  libxml2-dev \
  libxslt1-dev \
  zlib1g-dev \
  redis-server \
  git-core \
  subversion

RUN apt-get -y install \
  texlive-latex-recommended \
  texlive-fonts-recommended \
  texlive-latex-extra \
  doxygen \
  dvipng \
  graphviz

RUN apt-get -y install \
  nginx

RUN apt-get upgrade -y

# Project Configuration

RUN git clone --recurse-submodules https://github.com/rtfd/readthedocs.org.git
COPY ./local_settings.py ./readthedocs.org/readthedocs/settings/local_settings.py
COPY ./docker.py ./readthedocs.org/readthedocs/settings/docker.py
RUN mkdir /www
RUN mv ./readthedocs.org /www/readthedocs
WORKDIR /www/readthedocs

RUN git checkout tags/3.4.1

RUN $PYTHON -m pip install -r requirements.txt
RUN $PYTHON manage.py migrate

RUN echo \
  "from django.contrib.auth.models import User; \
  User.objects.create_superuser('$ADMIN_USERNAME', '$ADMIN_EMAIL', '$ADMIN_PASSWORD')" | \
  $PYTHON ./manage.py shell

RUN $PYTHON manage.py collectstatic --noinput
RUN $PYTHON manage.py loaddata test_data


# Server Running

RUN pip install gunicorn
RUN pip install setproctitle

COPY ./gunicorn_start.sh ./gunicorn_start.sh
RUN chmod u+x ./gunicorn_start.sh

RUN pip install supervisor
ADD ./supervisord.conf /etc/supervisord.conf

ENV PRODUCTION_DOMAIN=${DOMAIN}:${PORT}

COPY ./readthedocs.nginx.conf /etc/nginx/sites-available/readthedocs
RUN ln -s /etc/nginx/sites-available/readthedocs /etc/nginx/sites-enabled/readthedocs

RUN apt-get autoremove -y