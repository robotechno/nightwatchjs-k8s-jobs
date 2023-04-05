FROM ubuntu:20.04

ARG DEBIAN_FRONTEND="noninteractive"
ARG DEBCONF_NOWARNINGS="yes"
ARG DEBCONF_TERSE="yes"
ARG APT="apt-get -qq -y"
ARG LANG="C.UTF-8"

## Configure APT
RUN set -x \
  && echo "debconf debconf/frontend select ${DEBIAN_FRONTEND}" | debconf-set-selections \
  && echo 'APT::Install-Recommends "false";' | tee /etc/apt/apt.conf.d/99install-recommends \
  && echo 'APT::Get::Assume-Yes "true";' | tee /etc/apt/apt.conf.d/99assume-yes \
  && sed -Ei 's|^(DPkg::Pre-Install-Pkgs .*)|#\1|g' /etc/apt/apt.conf.d/70debconf \
  && debconf-show debconf

## Install Packages
RUN set -x \
  && mv /etc/apt/apt.conf.d/70debconf . \
  && ${APT} update \
  && ${APT} install apt-utils >/dev/null \
  && mv 70debconf /etc/apt/apt.conf.d \
  && ${APT} upgrade >/dev/null \
  && ${APT} install npm curl vim wget unzip libappindicator1 fonts-liberation

## Install Chrome
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -P /tmp
RUN ${APT} install /tmp/google-chrome-stable_current_amd64.deb
RUN ${APT} install xorg xvfb gtk2-engines-pixbuf dbus-x11 xfonts-base xfonts-100dpi xfonts-75dpi xfonts-cyrillic xfonts-scalable imagemagick x11-apps

## Install AWS CLI
RUN curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm -rf aws awscliv2.zip

## Prepare NightWatchJS
RUN mkdir -p /mnt/nightwatchjs/
COPY . /mnt/nightwatchjs/
WORKDIR /mnt/nightwatchjs/
RUN npm i
ENV DISPLAY ":99.0"

## Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT [ "./nightwatch-start.sh"]
