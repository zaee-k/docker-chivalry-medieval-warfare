FROM ubuntu
MAINTAINER pength <thierry.peng@gmail.com

################################################################################
## exposing 8000 and 27015 on udp
EXPOSE 8000:8000/udp
EXPOSE 27015:27015/udp

################################################################################
## app deps
RUN set -x && \
    dpkg --add-architecture i386 && \
    apt-get update -qq && \
    apt-get install -qq curl libstdc++6:i386 lib32gcc1

################################################################################
## cleaning as root
RUN apt-get clean autoclean purge && \
    rm -fr /tmp/*

RUN useradd -r -m -u 1000 steam

################################################################################
## volume
RUN mkdir -p /opt/chivalry && \
    chown steam -R /opt/chivalry && \
    chmod 755 -R /opt/chivalry

################################################################################
## copy run script
COPY run.sh /usr/local/bin/run-chivalry
## copy game.ini template
COPY PCServer-UDKGame.ini /usr/local/bin/PCServer-UDKGame.ini

################################################################################
## app run
USER steam
ENTRYPOINT ["/usr/local/bin/run-chivalry"]
