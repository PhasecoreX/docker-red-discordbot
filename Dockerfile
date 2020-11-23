FROM phasecorex/user-python:3.8-slim as noaudio-build

RUN set -eux; \
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

VOLUME /data



FROM noaudio-build as noaudio

ARG PCX_DISCORDBOT_COMMIT

ENV PCX_DISCORDBOT_COMMIT ${PCX_DISCORDBOT_COMMIT}
ENV PCX_DISCORDBOT_TAG noaudio

COPY root/ /

CMD ["/app/start-redbot.sh"]



FROM noaudio-build as audio-build

RUN set -eux; \
    mkdir -p /usr/share/man/man1/; \
# Install redbot audio dependencies
    apt-get update; \
    apt-get install -y --no-install-recommends \
        openjdk-11-jre-headless \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /usr/share/man/man1/;



FROM audio-build as audio

ARG PCX_DISCORDBOT_COMMIT

ENV PCX_DISCORDBOT_COMMIT ${PCX_DISCORDBOT_COMMIT}
ENV PCX_DISCORDBOT_TAG audio

COPY root/ /

CMD ["/app/start-redbot.sh"]



FROM audio-build as full-build

RUN set -eux; \
# Install popular cog dependencies
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # NotSoBot
        libmagickwand-dev \
        libaa1-dev \
        # CrabRave
        ffmpeg \
        imagemagick \
    ; \
    # CrabRave needs this policy removed
    sed -i '/@\*/d' /etc/ImageMagick-6/policy.xml; \
    rm -rf /var/lib/apt/lists/*;



FROM full-build as full

ARG PCX_DISCORDBOT_COMMIT

ENV PCX_DISCORDBOT_COMMIT ${PCX_DISCORDBOT_COMMIT}
ENV PCX_DISCORDBOT_TAG full

COPY root/ /

CMD ["/app/start-redbot.sh"]
