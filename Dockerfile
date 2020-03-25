ARG BASE_IMG
FROM ${BASE_IMG} as noaudio

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
# Install redbot dependencies
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        libssl-dev \
        libffi-dev \
        git \
        unzip \
    ; \
    rm -rf /var/lib/apt/lists/*; \
# Set up all three config locations
    mkdir -p /root/.config/Red-DiscordBot; \
    ln -s /config/config.json /root/.config/Red-DiscordBot/config.json; \
    mkdir -p /usr/local/share/Red-DiscordBot; \
    ln -s /config/config.json /usr/local/share/Red-DiscordBot/config.json; \
    mkdir -p /config/.config/Red-DiscordBot; \
    ln -s /config/config.json /config/.config/Red-DiscordBot/config.json;

COPY root/ /

VOLUME /data

CMD ["/app/start-redbot.sh"]

LABEL maintainer="Ryan Foster <phasecorex@gmail.com>"



FROM noaudio as audio

ENV PCX_DISCORDBOT_TAG audio

RUN set -eux; \
    mkdir -p /usr/share/man/man1/; \
# Install redbot audio dependencies
    apt-get update; \
    apt-get install -y --no-install-recommends \
        default-jre-headless \
    ; \
    rm -rf /var/lib/apt/lists/*;

CMD ["/app/start-redbot.sh"]



FROM audio as full

ENV PCX_DISCORDBOT_TAG full

RUN set -eux; \
# Install popular cog dependencies
    apt-get update; \
    apt-get install -y --no-install-recommends \
# Pip/Python
    # wand
        libmagickwand-dev \
    # python-aalib
        libaa1-dev \
# Pprograms
        ffmpeg \
    ; \
    rm -rf /var/lib/apt/lists/*;

CMD ["/app/start-redbot.sh"]
