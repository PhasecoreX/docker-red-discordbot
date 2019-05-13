ARG ARCH_IMG

FROM alpine
ARG DRONE_COMMIT_SHA
RUN : "${DRONE_COMMIT_SHA:?Build argument 'DRONE_COMMIT_SHA' needs to be set and non-empty.}"



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

ARG DRONE_COMMIT_SHA
ENV PCX_DISCORDBOT_COMMIT ${DRONE_COMMIT_SHA}

VOLUME /data

CMD ["/start-redbot.sh"]

LABEL maintainer="Ryan Foster <phasecorex@gmail.com>"
