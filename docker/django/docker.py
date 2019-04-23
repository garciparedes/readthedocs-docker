"""Docker deployment settings, including local_settings, if present."""
from __future__ import absolute_import

import os

from .base import CommunityBaseSettings


class CommunityDockerSettings(CommunityBaseSettings):
    """Settings for Docker deployment"""

    PRODUCTION_DOMAIN = 'localhost:8000'
    WEBSOCKET_HOST = 'localhost:8088'

    @property
    def DATABASES(self):  # noqa
        return {
            # 'default': {
            #     'ENGINE': 'django.db.backends.mysql',
            #     'NAME': 'db',
            #     'USER': 'root',
            #     'PASSWORD': 'docker_root',
            #     'HOST': 'mysql',
            #     'PORT': '3306',
            #     'TEST': {
            #         'NAME': 'db_test',
            #     },
            # }
            'default': {
                'ENGINE': 'django.db.backends.sqlite3',
                'NAME': os.path.join(self.SITE_ROOT, 'dev.db'),
            }
        }

    DONT_HIT_DB = False

    ACCOUNT_EMAIL_VERIFICATION = 'none'
    SESSION_COOKIE_DOMAIN = None
    CACHE_BACKEND = 'dummy://'

    SLUMBER_USERNAME = 'docker'
    SLUMBER_PASSWORD = 'docker'  # noqa: ignore dodgy check
    SLUMBER_API_HOST = 'http://127.0.0.1:8000'
    PUBLIC_API_URL = 'http://127.0.0.1:8000'

    BROKER_URL = 'redis://localhost:6379/0'
    CELERY_RESULT_BACKEND = 'redis://localhost:6379/0'
    CELERY_RESULT_SERIALIZER = 'json'
    CELERY_ALWAYS_EAGER = True
    CELERY_TASK_IGNORE_RESULT = False

    EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
    FILE_SYNCER = 'readthedocs.builds.syncers.LocalSyncer'

    CORS_ORIGIN_WHITELIST = (
        'localhost:8000',
    )

    # Disable auto syncing elasticsearch documents in development
    ELASTICSEARCH_DSL_AUTOSYNC = True

    @property
    def LOGGING(self):  # noqa - avoid pep8 N802
        logging = super().LOGGING
        logging['formatters']['default']['format'] = '[%(asctime)s] ' + self.LOG_FORMAT
        # Allow Sphinx and other tools to create loggers
        logging['disable_existing_loggers'] = False
        return logging


CommunityDockerSettings.load_settings(__name__)

if not os.environ.get('DJANGO_SETTINGS_SKIP_LOCAL', False):
    try:
        # pylint: disable=unused-wildcard-import
        from .local_settings import *  # noqa
    except ImportError:
        pass
