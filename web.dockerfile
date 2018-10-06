FROM centos:7
LABEL Author = "QuangPM"
LABEL Description = "DOCKERFILE : Allows the creation of a Container with a Centreon distribution installed via packages"

MAINTAINER quangpm@rikkeisoft.com
ENV DEBIAN_FRONTEND noninteractive
ENV http_proxy 'http://192.168.1.2:3128'
ENV https_proxy 'https://192.168.1.2:3128'

ENV container docker

# normal updates
RUN yum -y update

# nano
RUN yum -y install nano

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
 && rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

# php
RUN yum -y install php70w php70w-opcache php70w-cli php70w-common php70w-gd php70w-intl php70w-mbstring php70w-mcrypt php70w-mysql php70w-mssql php70w-pdo php70w-pear php70w-soap php70w-xml php70w-xmlrpc

# apache
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
  systemd-tmpfiles-setup.service ] || rm -f $i; done); \
  rm -f /lib/systemd/system/multi-user.target.wants/*;\
  rm -f /etc/systemd/system/*.wants/*;\
  rm -f /lib/systemd/system/local-fs.target.wants/*; \
  rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
  rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
  rm -f /lib/systemd/system/basic.target.wants/*;\
  rm -f /lib/systemd/system/anaconda.target.wants/*;
#VOLUME [ "/sys/fs/cgroup" ]
RUN yum -y install httpd

# tools cron
RUN yum -y install epel-release iproute at curl crontabs git

# pagespeed
RUN curl -O https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_x86_64.rpm \
 && rpm -U mod-pagespeed-*.rpm \
 && yum clean all \
 && rm -rf /etc/localtime \
 && ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# we want some config changes
COPY config/php_settings.ini /etc/php.d/
COPY config/v-host.conf /etc/httpd/conf.d/

# create webserver-default directory
RUN mkdir -p /var/www/html

EXPOSE 80

RUN systemctl enable httpd.service && systemctl start crond

CMD ["/usr/sbin/init"]
