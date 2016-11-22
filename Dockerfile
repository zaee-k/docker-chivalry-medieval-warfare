FROM ubuntu
MAINTAINER Caderrik <caderrik@gmail.com>

################################################################################
## app infos
ENV ADMINPASSWORD="changeit" INSTALL_DIR=/chivalry
VOLUME ["/chivalry"]
EXPOSE 7000 7010

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
RUN mkdir -p "${INSTALL_DIR}" && \
    chown steam -R "${INSTALL_DIR}" && \
    chmod 755 -R "${INSTALL_DIR}"

################################################################################
## app config
COPY run.sh /usr/local/bin/run-chivalry

################################################################################
## app run
USER steam
ENTRYPOINT ["/usr/local/bin/run-chivalry"]
