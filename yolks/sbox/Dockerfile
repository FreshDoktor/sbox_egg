FROM ghcr.io/parkervcp/yolks:ubuntu

LABEL author="FreshDoktor" maintainer="freshdoktor@freshgaming.eu"

ENV DEBIAN_FRONTEND=noninteractive

# .NET 10 Runtime + SteamCMD dependencies + libgdiplus for s&box
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        wget apt-transport-https ca-certificates curl iproute2 tini \
        lib32gcc-s1 lib32stdc++6 libgdiplus \
    && wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh --runtime dotnet --channel 10.0 --install-dir /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm /tmp/dotnet-install.sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# OpenSSL: cap at TLS 1.2 — Ubuntu 24.04's openssl.cnf has no ssl_conf section
# by default, so we add one. .NET's async OpenSSL interop (SSL_read non-blocking)
# fails with SSL_ERROR_SSL on TLS 1.3 session ticket post-handshake messages
# under OpenSSL 3.0.x; curl is unaffected because libcurl uses a different path.
RUN sed -i '/^\[openssl_init\]/a ssl_conf = ssl_sect' /etc/ssl/openssl.cnf \
    && printf '\n[ssl_sect]\nsystem_default = ssl_default_sect\n\n[ssl_default_sect]\nMinProtocol = TLSv1.2\nMaxProtocol = TLSv1.2\nCipherString = DEFAULT@SECLEVEL=1\n' >> /etc/ssl/openssl.cnf

# SteamCMD
ENV STEAMCMD_DIR="/opt/steamcmd"
RUN mkdir -p "${STEAMCMD_DIR}" \
    && curl -sqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
        | tar -xzvf - -C "${STEAMCMD_DIR}" \
    && chmod -R 755 "${STEAMCMD_DIR}" \
    && chown -R container:container "${STEAMCMD_DIR}"

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

STOPSIGNAL SIGINT

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
