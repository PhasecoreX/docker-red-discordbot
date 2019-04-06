ARG ARCH_IMG

FROM ${ARCH_IMG}

MAINTAINER Ryan Foster <phasecorex@gmail.com>

RUN set -eux; \
    apk add --no-cache \
# Redbot dependencies
        build-base \
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
