FROM phasecorex/user-python:3.7-alpine

MAINTAINER Ryan Foster <phasecorex@gmail.com>

RUN set -eux; \
    apk add --no-cache \
        openjdk8-jre \
        unzip \
        gcc \
        musl-dev \
        git; \
    pip3 install --upgrade pip setuptools; \
    pip3 install -U --process-dependency-links --force-reinstall --no-cache-dir Red-DiscordBot[voice]; \
    redbot --version

COPY root/ /

VOLUME /data

CMD ["redbot", "docker"]
