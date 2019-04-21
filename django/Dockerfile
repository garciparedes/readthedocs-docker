FROM ubuntu:18.04

# Environment Variables

ARG SVN_USERNAME
ARG SVN_PASSWORD
ARG ADMIN_USERNAME
ARG ADMIN_EMAIL
ARG ADMIN_PASSWORD

ENV PORT=8000 \
    DOMAIN=0.0.0.0 \
    DEBIAN_FRONTEND=noninteractive \
    PYTHON=python3.6 \
    PYTHON_VERSION_27=2.7.15 \
    PYTHON_VERSION_35=3.5.7 \
    PYTHON_VERSION_36=3.6.8 \
    PYTHON_VERSION_37=3.7.3 \
    PRODUCTION_DOMAIN=${DOMAIN}:${PORT}


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
  subversion \
  nginx

RUN apt-get -y install \
  texlive-latex-recommended \
  texlive-fonts-recommended \
  texlive-latex-extra \
  doxygen \
  dvipng \
  graphviz

RUN apt-get install -y \
  gcc \
  make \
  libssl-dev \
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

RUN curl https://pyenv.run | bash
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN eval "$(pyenv init -)"
RUN eval "$(pyenv virtualenv-init -)"

RUN pyenv install $PYTHON_VERSION_36 && \
    pyenv install $PYTHON_VERSION_37 && \
    pyenv install $PYTHON_VERSION_35 && \
    pyenv install $PYTHON_VERSION_27
RUN pyenv global \
    $PYTHON_VERSION_36 \
    $PYTHON_VERSION_37 \
    $PYTHON_VERSION_35 \
    $PYTHON_VERSION_27

RUN apt-get upgrade -y
RUN apt-get autoremove -y


# Setting Up environment.

# COPY ./ssh-keys/* ~/.ssh/


# Setting Up Project

RUN git clone --recurse-submodules https://github.com/rtfd/readthedocs.org.git
COPY ./local_settings.py ./readthedocs.org/readthedocs/settings/local_settings.py
COPY ./docker.py ./readthedocs.org/readthedocs/settings/docker.py
RUN mkdir /www
RUN mv ./readthedocs.org /www/readthedocs
WORKDIR /www/readthedocs

RUN git checkout tags/3.4.1

RUN $PYTHON -m pip install -r requirements.txt
RUN $PYTHON manage.py migrate

RUN echo "from django.contrib.auth.models import User; \
  User.objects.create_superuser('$ADMIN_USERNAME', '$ADMIN_EMAIL', '$ADMIN_PASSWORD')" | \
  $PYTHON ./manage.py shell;

RUN $PYTHON manage.py collectstatic --noinput
RUN $PYTHON manage.py loaddata test_data

# Setting Up Server

COPY ./gunicorn_start.sh ./gunicorn_start.sh
RUN chmod u+x ./gunicorn_start.sh

ADD ./supervisord.conf /etc/supervisord.conf

COPY ./readthedocs.nginx.conf /etc/nginx/sites-available/readthedocs
RUN ln -s /etc/nginx/sites-available/readthedocs /etc/nginx/sites-enabled/readthedocs

RUN python -m pip install \
  gunicorn \
  setproctitle \
  supervisor