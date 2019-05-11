ARG ARCH_IMG

FROM alpine
ARG COMMIT_SHA
RUN : "${COMMIT_SHA:?Build argument 'COMMIT_SHA' needs to be set and non-empty.}"



FROM ${ARCH_IMG}

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

ARG COMMIT_SHA
ENV PCX_DISCORDBOT_COMMIT ${COMMIT_SHA}

VOLUME /data

CMD ["/start-redbot.sh"]

LABEL maintainer="Ryan Foster <phasecorex@gmail.com>"
