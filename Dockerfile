ARG BASE_IMG
FROM ${BASE_IMG} as noaudio

LABEL maintainer="Ryan Foster <phasecorex@gmail.com>"

ARG DRONE_COMMIT_SHA
ENV PCX_DISCORDBOT_COMMIT ${DRONE_COMMIT_SHA}
ENV PCX_DISCORDBOT_TAG noaudio

RUN set -eux; \
# Check that DRONE_COMMIT_SHA exists
    if [ "x$DRONE_COMMIT_SHA" = "x" ]; then \
        echo Build argument 'DRONE_COMMIT_SHA' needs to be set and non-empty.; \
        exit 1; \
    else \
        echo DRONE_COMMIT_SHA=${DRONE_COMMIT_SHA}; \
    fi; \
# Install Red-DiscordBot dependencies
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # Red-DiscordBot
        build-essential \
        git \
        # ssh repo support
        openssh-client \
        # start-redbot.sh
        jq \
    ; \
    rm -rf /var/lib/apt/lists/*; \
# Set up all three config locations
    mkdir -p /root/.config/Red-DiscordBot; \
    ln -s /data/config.json /root/.config/Red-DiscordBot/config.json; \
    mkdir -p /usr/local/share/Red-DiscordBot; \
    ln -s /data/config.json /usr/local/share/Red-DiscordBot/config.json; \
    mkdir -p /config/.config/Red-DiscordBot; \
    ln -s /data/config.json /config/.config/Red-DiscordBot/config.json;

COPY root/ /

VOLUME /data

CMD ["/app/start-redbot.sh"]



FROM noaudio as audio

ENV PCX_DISCORDBOT_TAG audio

RUN set -eux; \
    mkdir -p /usr/share/man/man1/; \
# Install redbot audio dependencies
    apt-get update; \
    apt-get install -y --no-install-recommends \
        openjdk-11-jre-headless \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /usr/share/man/man1/;

CMD ["/app/start-redbot.sh"]



FROM audio as full

ENV PCX_DISCORDBOT_TAG full

RUN set -eux; \
# Install popular cog dependencies
    buildDeps=' \
        wget \
    '; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
# Build deps
        $buildDeps \
# Python
    # python-aalib
        libaa1-dev \
# Programs
        ffmpeg \
    ; \
# Build latest ImageMagick (Python wand)
    wget ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick.tar.gz; \
    tar xvfz ImageMagick.tar.gz; \
    cd ImageMagick-*; \
    ./configure; \
    make; \
    make install; \
    ldconfig /usr/local/lib; \
    cd ..; \
    rm -rf ImageMagick*; \
# Clean up
    apt-get purge -y --auto-remove $buildDeps; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /usr/local/share/doc/ImageMagick*;

CMD ["/app/start-redbot.sh"]
