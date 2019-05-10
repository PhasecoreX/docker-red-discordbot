ARG ARCH_IMG

FROM ${ARCH_IMG}

ENV PCX_DISCORDBOT true

RUN set -eux; \
    apk add --no-cache \
# Redbot dependencies
        build-base \
        git \
        openjdk8-jre \
        unzip \
# Popular cog dependencies (python)
    # matplotlib
        freetype-dev \
        libpng-dev \
    # pillow
        jpeg-dev \
    # lxml
        libxml2-dev \
        libxslt-dev \
# Popular cog dependencies (programs)
        imagemagick \
        imagemagick-dev \
        ffmpeg \
        ffmpeg-dev \
    ;

COPY root/ /

VOLUME /data

CMD ["/start-redbot.sh"]

LABEL maintainer="Ryan Foster <phasecorex@gmail.com>"
