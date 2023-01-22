FROM python:3.11-slim-bullseye as core-build

# Add PhasecoreX user-entrypoint script
ADD https://raw.githubusercontent.com/PhasecoreX/docker-user-image/master/user-entrypoint.sh /bin/user-entrypoint
RUN chmod +x /bin/user-entrypoint && /bin/user-entrypoint --init
ENTRYPOINT ["/bin/user-entrypoint"]

RUN set -eux; \
# Install Red-DiscordBot dependencies
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # Red-DiscordBot
        build-essential \
        git \
        # Required for building PyNaCl
        libsodium-dev \
        # Required for building CFFI
        libffi-dev \
        # start-redbot.sh
        jq \
        # ssh repo support
        openssh-client \
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

ENV SODIUM_INSTALL system



FROM core-build as core

ARG PCX_DISCORDBOT_BUILD
ARG PCX_DISCORDBOT_COMMIT

ENV PCX_DISCORDBOT_BUILD ${PCX_DISCORDBOT_BUILD}
ENV PCX_DISCORDBOT_COMMIT ${PCX_DISCORDBOT_COMMIT}
ENV PCX_DISCORDBOT_TAG core

COPY root/ /

CMD ["/app/start-redbot.sh"]

#######################################################################################

FROM core-build as extra-build

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
        # RSS (SciPy has no wheels for armv7)
        $([ "$(uname --machine)" = "armv7l" ] && echo "gfortran libopenblas-dev liblapack-dev") \
        # ReTrigger
        tesseract-ocr \
    ; \
    # CrabRave needs this policy removed
    sed -i '/@\*/d' /etc/ImageMagick-6/policy.xml; \
    rm -rf /var/lib/apt/lists/*;



FROM extra-build as extra

ARG PCX_DISCORDBOT_BUILD
ARG PCX_DISCORDBOT_COMMIT

ENV PCX_DISCORDBOT_BUILD ${PCX_DISCORDBOT_BUILD}
ENV PCX_DISCORDBOT_COMMIT ${PCX_DISCORDBOT_COMMIT}
ENV PCX_DISCORDBOT_TAG extra

COPY root/ /

CMD ["/app/start-redbot.sh"]

#######################################################################################

FROM core-build as core-audio-build

RUN set -eux; \
# Install redbot audio dependencies
    apt-get update; \
    apt-get install -y --no-install-recommends \
        openjdk-11-jre-headless \
    ; \
    rm -rf /var/lib/apt/lists/*;



FROM core-audio-build as core-audio

ARG PCX_DISCORDBOT_BUILD
ARG PCX_DISCORDBOT_COMMIT

ENV PCX_DISCORDBOT_BUILD ${PCX_DISCORDBOT_BUILD}
ENV PCX_DISCORDBOT_COMMIT ${PCX_DISCORDBOT_COMMIT}
ENV PCX_DISCORDBOT_TAG core-audio

COPY root/ /

CMD ["/app/start-redbot.sh"]

#######################################################################################

FROM extra-build as extra-audio-build

RUN set -eux; \
# Install redbot audio dependencies
    apt-get update; \
    apt-get install -y --no-install-recommends \
        openjdk-11-jre-headless \
    ; \
    rm -rf /var/lib/apt/lists/*;



FROM extra-audio-build as extra-audio

ARG PCX_DISCORDBOT_BUILD
ARG PCX_DISCORDBOT_COMMIT

ENV PCX_DISCORDBOT_BUILD ${PCX_DISCORDBOT_BUILD}
ENV PCX_DISCORDBOT_COMMIT ${PCX_DISCORDBOT_COMMIT}
ENV PCX_DISCORDBOT_TAG extra-audio

COPY root/ /

CMD ["/app/start-redbot.sh"]


#######################################################################################

FROM core-build as pylav-core-build

RUN set -eux; \
# Install redbot audio dependencies
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libaio1  \
        libaio-dev \
        gnupg \
        ca-certificates \
        curl \
    ; \
    # Users should be using a docker container ghcr.io/drapersniper/pylav-node:master instead of a manage node
    #  But not all users will be aware of this to lets install java for them
    curl -s https://repos.azul.com/azul-repo.key | gpg --dearmor -o /usr/share/keyrings/azul.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | tee /etc/apt/sources.list.d/zulu.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        zulu19-ca-jdk-headless; \
    rm -rf /var/lib/apt/lists/*; \
    rm /etc/apt/sources.list.d/zulu.list; \
    rm /usr/share/keyrings/azul.gpg; \
    mkdir -p /data/pylav;


FROM pylav-core-build as pylav-core

ARG PCX_DISCORDBOT_BUILD
ARG PCX_DISCORDBOT_COMMIT

ENV PCX_DISCORDBOT_BUILD ${PCX_DISCORDBOT_BUILD}
ENV PCX_DISCORDBOT_COMMIT ${PCX_DISCORDBOT_COMMIT}
ENV PCX_DISCORDBOT_TAG pylav-core
ENV PYLAV__DATA_FOLDER /data/pylav
ENV PYLAV__YAML_CONFIG /data/pylav/pylav.yaml

COPY root/ /

CMD ["/app/start-redbot.sh"]


#######################################################################################

FROM extra-build as pylav-extra-build

RUN set -eux; \
# Install redbot audio dependencies
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libaio1  \
        libaio-dev \
        gnupg \
        ca-certificates \
        curl \
    ; \
    # Users should be using a docker container ghcr.io/drapersniper/pylav-node:master instead of a manage node
    #  But not all users will be aware of this to lets install java for them
    curl -s https://repos.azul.com/azul-repo.key | gpg --dearmor -o /usr/share/keyrings/azul.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | tee /etc/apt/sources.list.d/zulu.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        zulu19-ca-jdk-headless; \
    rm -rf /var/lib/apt/lists/*; \
    rm /etc/apt/sources.list.d/zulu.list; \
    rm /usr/share/keyrings/azul.gpg; \
    mkdir -p /data/pylav;


FROM pylav-extra-build as pylav-extra

ARG PCX_DISCORDBOT_BUILD
ARG PCX_DISCORDBOT_COMMIT

ENV PCX_DISCORDBOT_BUILD ${PCX_DISCORDBOT_BUILD}
ENV PCX_DISCORDBOT_COMMIT ${PCX_DISCORDBOT_COMMIT}
ENV PCX_DISCORDBOT_TAG pylav-extra
ENV PYLAV__DATA_FOLDER /data/pylav
ENV PYLAV__YAML_CONFIG /data/pylav/pylav.yaml

COPY root/ /

CMD ["/app/start-redbot.sh"]

#######################################################################################