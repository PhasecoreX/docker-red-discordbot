FROM phasecorex/user-python:3.7-alpine

MAINTAINER Ryan Foster <phasecorex@gmail.com>

RUN set -eux; \
    apk add --no-cache \
# Redbot dependencies
        alpine-sdk \
        git \
        openjdk8-jre \
        unzip \
# Popular cog dependencies
    # matplotlib
        freetype-dev \
        libpng-dev \
    # pillow
        jpeg-dev \
    # lxml
        libxml2-dev \
        libxslt-dev \
    # imagemagick
        imagemagick-dev \
    ;

COPY root/ /

VOLUME /data

CMD ["/start-redbot.sh"]
