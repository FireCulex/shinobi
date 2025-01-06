FROM node:alpine

ENV S_HOME /opt/shinobi
ENV COMMIT e197f067

WORKDIR $S_HOME

RUN apk add ffmpeg git patch

RUN git clone https://gitlab.com/Shinobi-Systems/Shinobi $S_HOME \
    && rm -rf .git

RUN npm install \
    && npm install pm2 -g \
    && npm install ftp-srv \
    && npm cache clean --force

COPY ./shinobi.patch /tmp/shinobi.patch
RUN patch -p0 -R < /tmp/shinobi.patch

ENTRYPOINT pm2 start camera.js && pm2 logs --lines 200
