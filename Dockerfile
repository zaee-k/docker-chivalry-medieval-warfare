FROM ubuntu
MAINTAINER Caderrik <caderrik@gmail.com>

RUN set -x && \
    dpkg --add-architecture i386 && \
    apt-get update -qq && \
    apt-get install -qq curl libstdc++6:i386 lib32gcc1

RUN useradd -m -u 1000 steam

COPY run.sh /usr/local/bin/run-chivalry

RUN mkdir -p /chivalry && \
    chown -R steam:steam /chivalry && \
    chmod +x /usr/local/bin/run-chivalry

USER steam
VOLUME ["/chivalry"]
ENTRYPOINT ["/usr/local/bin/run-chivalry"]
