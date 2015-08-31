FROM mono:4
MAINTAINER Arnaud Dartois <nonobis@gmail.com>

ENV VERSION 0.6.3

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update -q
RUN apt-get install -qy libcurl4-openssl-dev tar wget
RUN apt-get clean
RUN wget --no-check-certificate --secure-protocol=TLSv1 https://jackett.net/Download/v${VERSION}/Jackett.Mono.v${VERSION}.tar.bz2 -O /tmp/jackett.tar.bz2
RUN mkdir -p /tmp/jackett
RUN tar -jxvf /tmp/jackett.tar.bz2 -C /tmp/jackett
RUN mv /tmp/jackett/Jackett /app
RUN chown -R nobody:users /app
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN mkdir -p /config
RUN chown -R nobody:users /config
RUN ln -s /config /usr/share/Jackett

EXPOSE 9117
VOLUME /config
VOLUME /app

ADD start.sh /
RUN chmod +x /start.sh

# Currently there is a bug in Jackett where running as non-root user causes the app to not start up
# See: https://github.com/zone117x/Jackett/issues/37
# We could potentially start it initially as root and then kill it and then start as nobody, but for now, hoping
# the bug gets resolved.
#USER nobody
WORKDIR /app

ENTRYPOINT ["/start.sh"]
