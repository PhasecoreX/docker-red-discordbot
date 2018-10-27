FROM phasecorex/user-python:alpine

MAINTAINER Ryan Foster <phasecorex@gmail.com>

RUN apk add --no-cache \
        openjdk8-jre \
        unzip \
        gcc \
        musl-dev \
        git \
    && pip3 install --upgrade pip setuptools \
    && pip3 install -U --process-dependency-links --force-reinstall --no-cache-dir Red-DiscordBot[voice]

COPY root/ /

VOLUME /data

CMD ["redbot", "docker"]
