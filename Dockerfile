ARG DOCKER_LOGIN_SERVER=batchr3devcr.azurecr.io
FROM ${DOCKER_LOGIN_SERVER}/batchr3-kettle5:1.0.1

FROM ubuntu:20.04

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends supervisor \
        pwgen sudo vim-tiny x11vnc  \
        net-tools \
        lxde x11vnc xvfb \
        gtk2-engines-murrine ttf-ubuntu-font-family \
        libreoffice firefox \
        fonts-wqy-microhei \
        curl \
        jq \
        nginx \
        gedit \
        openjdk-8-jdk \
        python3-pip python-dev build-essential python-setuptools \
        mesa-utils libgl1-mesa-dri \
    && apt-get autoclean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*




COPY --from=0 /dv1/bps_r3/kettle /dv1/bps_r3/kettle
COPY lib/* /dv1/bps_r3/kettle/lib/
# tini for subreap                                   
ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /bin/tini
RUN chmod +x /bin/tini

ADD noVNC /noVNC/
ADD nginx.conf /etc/nginx/sites-enabled/default
ADD startup.sh /
ADD supervisord.conf /etc/supervisor/conf.d/
ADD doro-lxde-wallpapers /usr/share/doro-lxde-wallpapers/

EXPOSE 6080
WORKDIR /root
ENTRYPOINT ["/startup.sh"]
