FROM centos:latest

RUN yum -y update
RUN yum -y install \
        curl \
        git \
        python \
        make \
        automake \
        gcc \
        gcc-c++ \
        kernel-devel \
        xorg-x11-server-Xvfb \
        git-core

RUN yum -y install epel-release yum-utils
RUN yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
RUN yum-config-manager --enable remi
RUN yum install -y redis

RUN curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -
RUN yum install -y nodejs

RUN npm install -g yarn
RUN npm install -g pm2
RUN pm2 install pm2-logrotate

ENV LL_TAG=v2.8.2
RUN git clone https://github.com/LearningLocker/learninglocker.git /opt/learninglocker \
    && cd /opt/learninglocker \
    && git checkout $LL_TAG

WORKDIR /opt/learninglocker

COPY .env .env

RUN yarn install \
    && yarn build-all


RUN cp -r storage storage.template

EXPOSE 3000 8080

RUN yarn migrate

#RUN pm2 start pm2/all.json
#RUN pm2 startup
#RUN pm2 status

RUN node cli/dist/server createSiteAdmin "example@example.ru" "Example" "Qwerty123"

RUN yum -y install nginx

RUN mkdir /etc/nginx/sites-available
RUN mkdir /etc/nginx/sites-enabled
COPY learninglocker.conf /etc/nginx/sites-available/learninglocker.conf
COPY nginx.conf /etc/nginx/nginx.conf
RUN ln -s /etc/nginx/sites-available/learninglocker.conf /etc/nginx/sites-enabled/learninglocker.conf

#RUN pm2 start pm2/all.json
CMD ["/usr/sbin/init"]
