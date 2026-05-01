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

# OpenSSL: cap at TLS 1.2 and lower security level — s&box backend triggers
# SSL_ERROR_SSL during decryption when TLS 1.3 KeyUpdate is negotiated with
# OpenSSL 3.0.x on Ubuntu 24.04 via .NET's P/Invoke layer.
RUN sed -i 's/@SECLEVEL=2/@SECLEVEL=1/g' /etc/ssl/openssl.cnf \
    && sed -i '/^MinProtocol\s*=/a MaxProtocol = TLSv1.2' /etc/ssl/openssl.cnf

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
