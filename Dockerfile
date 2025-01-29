FROM node:alpine

ENV S_HOME /opt/shinobi
ENV COMMIT e197f067

WORKDIR $S_HOME

RUN apk add --no-cache \
    ffmpeg \
    git \
    patch \
    libva-utils \
    libva-intel-driver

RUN git clone https://gitlab.com/Shinobi-Systems/Shinobi $S_HOME \
    && rm -rf .git

RUN npm install \
    && npm install pm2 -g \
    && npm install ftp-srv \
    && npm cache clean --force

COPY ./rw_timeout.patch /tmp/rw_timeout.patch

RUN patch -p0 < /tmp/rw_timeout.patch

COPY ./aac2copy.patch /tmp/aac2copy.patch

RUN patch -p0 -R < /tmp/aac2copy.patch

RUN echo {} > conf.json

RUN node tools/modifyConfiguration.js addToConfig='{ \
   "port": 8080, \
   "passwordType": "sha256", \
   "debugLog": false, \
   "streamDir": "/var/lib/shinobi/stream", \
   "videosDir": "/var/lib/shinobi/video",\
   "binDir": "/var/lib/shinobi/files", \
   "dropInEventServer":true, \
   "ftpServer":true, \
   "ftpServerPort": 1337 \
}'

RUN node tools/modifyConfiguration.js addToConfig='{ \
   "databaseType": "mysql", \
   "db": { \
      "host": "mysql-container", \
      "user": "majesticflame", \
      "password": "cool", \
      "database": "ccio", \
      "port": 3306 \
   } \
}'

RUN node tools/modifyConfiguration.js addToConfig='{ \
  "mail": { \
    "service": "gmail", \
    "auth": { \
      "user": "fireculex@gmail.com", \
      "pass": "mhgehjydqpurqmuy" \
    } \
  } \
}'

ENTRYPOINT pm2 start camera.js && pm2 logs
