FROM debian:bookworm-slim

# .NET Runtime installieren
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget apt-transport-https ca-certificates \
    && wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh --runtime dotnet --channel 9.0 --install-dir /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm /tmp/dotnet-install.sh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# SteamCMD
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends lib32gcc-s1 lib32stdc++6 curl \
    && mkdir -p /opt/steamcmd \
    && curl -sqL https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
       | tar -xzvf - -C /opt/steamcmd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# User setup (Pelican standard)
RUN useradd -m -d /home/container -s /bin/bash container \
    && chown -R container:container /opt/steamcmd

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER container
ENV HOME=/home/container
WORKDIR /home/container

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
