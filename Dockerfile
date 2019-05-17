ARG ARCH_IMG
FROM ${ARCH_IMG}

RUN set -eux; \
    mkdir -p /usr/share/man/man1/; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
# Redbot dependencies
        default-jre-headless \
    ; \
    rm -rf /var/lib/apt/lists/*;
