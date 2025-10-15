FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /tmp

# set ports
EXPOSE 38050

RUN apt-get update
RUN apt-get install -y \
wget \
unzip \
mc \
nano \
ffmpeg \
tzdata
RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get autoremove -y

# install hlsproxy - detect architecture and download appropriate binary
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
        HLSPROXY_ARCH="arm64"; \
    elif [ "$ARCH" = "x86_64" ]; then \
        HLSPROXY_ARCH="x64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    echo "Downloading HLS Proxy for architecture: $HLSPROXY_ARCH" && \
    wget https://www.hls-proxy.com/downloads/8.4.8/hls-proxy-8.4.8.linux-${HLSPROXY_ARCH}.zip -O hlsproxy.zip && \
    unzip hlsproxy.zip -d /opt/ && \
    rm hlsproxy.zip 

# clean up
RUN apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
/usr/share/man /usr/share/groff /usr/share/info \
/usr/share/lintian /usr/share/linda /var/cache/man /usr/share/doc/*
#COPY root/ /
RUN chmod +x /opt/hls-proxy
CMD ["/opt/hls-proxy"]

