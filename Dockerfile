FROM node
RUN apt-get update
RUN apt-get install -y git build-essential premake4 libfreetype6-dev libevent-dev libsqlite3-dev liblua5.2-dev mono-complete

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY package.json /usr/src/app/
RUN npm install
COPY . /usr/src/app
WORKDIR /usr/src/app/ygopro
# ADD https://mycard.moe/ygopro/cards.cdb cards.cdb
RUN premake4 --os=linux --platform=x64 gmake
RUN ln -s /usr/lib/x86_64-linux-gnu/liblua5.2.so /usr/lib/liblua.so
WORKDIR /usr/src/app/ygopro/build
RUN make config=release ygopro
WORKDIR /usr/src/app/ygopro
RUN ln -s bin/release/ygopro ygopro
RUN strip ygopro

RUN mv /usr/src/app/windbot /usr/src/app/windbot-source
WORKDIR /usr/src/app/windbot-source
RUN xbuild /property:Configuration=Release /property:OutDir=/usr/src/app/windbot/
WORKDIR /usr/src/app
RUN rm -rf /usr/src/app/windbot-source
RUN ln -s /usr/src/app/ygopro/cards.cdb /usr/src/app/windbot/cards.cdb

WORKDIR /usr/src/app
CMD [ "npm", "start" ]
