FROM python:3.6

# Environment Variables

ENV PORT=8000 \
    DOMAIN=0.0.0.0 \
    ADMIN_USERNAME=admin \
    ADMIN_EMAIL=email@localhost \
    ADMIN_PASSWORD=admin \
    SVN_USERNAME=svn_user \
    SVN_PASSWORD=svn_password

ENV DEBIAN_FRONTEND=noninteractive \
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


# Environment Configuration

RUN alias svn="svn --username $SVN_USERNAME --password $SVN_PASSWORD"


# Project Configuration

RUN git clone --recurse-submodules https://github.com/rtfd/readthedocs.org.git
WORKDIR readthedocs.org

RUN git checkout tags/3.4.1

RUN $PYTHON -m pip install -r requirements.txt
RUN $PYTHON manage.py migrate

RUN echo "from django.contrib.auth.models \
  import User; User.objects.create_superuser('$ADMIN_USERNAME', '$ADMIN_EMAIL', '$ADMIN_PASSWORD')" | \
  $PYTHON ./manage.py shell

RUN $PYTHON manage.py collectstatic
RUN $PYTHON manage.py loaddata test_data


# Server Running

EXPOSE $PORT:8000
CMD $PYTHON manage.py runserver $DOMAIN:8000
