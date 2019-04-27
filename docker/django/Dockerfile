FROM ubuntu:18.04

# Environment Variables

ARG PORT
ARG DOMAIN

ARG SVN_USERNAME
ARG SVN_PASSWORD

ARG ADMIN_USERNAME
ARG ADMIN_EMAIL
ARG ADMIN_PASSWORD

ENV DEBIAN_FRONTEND=noninteractive

ENV PYTHON=python3.6 \
    PYTHON_VERSION_27=2.7.15 \
    PYTHON_VERSION_35=3.5.7 \
    PYTHON_VERSION_36=3.6.8 \
    PYTHON_VERSION_37=3.7.3

ENV PRODUCTION_DOMAIN=${DOMAIN}:${PORT}


# Package Installation

RUN apt-get update && apt-get install -y --no-install-recommends \
      apt-utils

RUN apt-get update && apt-get -y install \
      software-properties-common \
      vim

RUN apt-get update && apt-get -y install \
      build-essential \
      libxml2-dev \
      libxslt1-dev \
      zlib1g-dev \
      redis-server \
      git-core \
      subversion \
      nginx \
      libmysqlclient-dev

RUN apt-get update && apt-get -y install \
      texlive-latex-recommended \
      texlive-fonts-recommended \
      texlive-latex-extra \
      doxygen \
      dvipng \
      graphviz

RUN apt-get update && apt-get -y install \
      gcc \
      make \
      libssl-dev \
      libpq-dev \
      zlib1g-dev \
      libbz2-dev \
      libreadline-dev \
      libsqlite3-dev \
      wget \
      curl \
      llvm \
      libncurses5-dev \
      libncursesw5-dev \
      xz-utils \
      tk-dev \
      libffi-dev \
      liblzma-dev \
      python-openssl

# Setting Up Python.

## Installing pyenv

RUN curl https://pyenv.run | bash
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN eval "$(pyenv init -)"
RUN eval "$(pyenv virtualenv-init -)"

## Installing Python versions

RUN pyenv install $PYTHON_VERSION_36 && \
    pyenv install $PYTHON_VERSION_37 && \
    pyenv install $PYTHON_VERSION_35 && \
    pyenv install $PYTHON_VERSION_27
RUN pyenv global \
    $PYTHON_VERSION_36 \
    $PYTHON_VERSION_37 \
    $PYTHON_VERSION_35 \
    $PYTHON_VERSION_27

## Installing missing packages

RUN python3.5 -m pip install virtualenv

RUN pip install \
  gunicorn \
  setproctitle \
  supervisor

# Setting Up environment.

# COPY ./ssh-keys/* ~/.ssh/


# Setting Up Project

RUN mkdir /www
COPY ./readthedocs/ /www/readthedocs
WORKDIR /www/readthedocs

RUN $PYTHON -m pip install -r requirements.txt
RUN $PYTHON -m pip install mysqlclient
RUN $PYTHON manage.py migrate

RUN echo "from django.contrib.auth.models import User; \
  User.objects.create_superuser('$ADMIN_USERNAME', '$ADMIN_EMAIL', '$ADMIN_PASSWORD')" | \
  $PYTHON ./manage.py shell;

RUN $PYTHON manage.py collectstatic --noinput
RUN $PYTHON manage.py loaddata test_data

# Setting Up Server

COPY ./docker/django/gunicorn_start.sh ./gunicorn_start.sh
RUN chmod u+x ./gunicorn_start.sh

COPY ./docker/django/supervisord.conf /etc/supervisord.conf

COPY ./docker/django/readthedocs.nginx.conf /etc/nginx/sites-available/readthedocs
RUN ln -s /etc/nginx/sites-available/readthedocs /etc/nginx/sites-enabled/readthedocs
