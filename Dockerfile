FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /tmp

# set ports
EXPOSE 38050

RUN apt-get update 
RUN apt-get install -y \
wget \
mc \
nano \
ffmpeg \
tzdata
RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime  
RUN dpkg-reconfigure --frontend noninteractive tzdata 
RUN apt-get autoremove -y 

# install hlsproxy
RUN wget -o - https://www.hls-proxy.com/downloads/8.4.8/hls-proxy-8.4.8.linux-arm64.zip -O hlsproxy.zip && unzip hlsproxy.zip -d /opt/ 

# clean up
RUN apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
/usr/share/man /usr/share/groff /usr/share/info \
/usr/share/lintian /usr/share/linda /var/cache/man /usr/share/doc/*
#COPY root/ /
RUN chmod +x /opt/hls-proxy
CMD ["/opt/hls-proxy"]

