# Start your image with a node base image
FROM node:18-alpine
FROM ubuntu:20.04


# The /app directory should act as the main application directory
WORKDIR /app

# Copy the app package and package-lock.json file
COPY package*.json ./

# Copy local directories to the current local directory of our docker image (/app)
COPY ./src ./src
COPY ./public ./public

ARG DEBIAN_FRONTEND=nointeractive
RUN apt update
RUN apt-get install -y curl

ENV PACKAGES="\
  build-essential \
  libcurl4-openssl-dev \
  software-properties-common \
  ubuntu-drivers-common \
  build-essential \
  git \
  libtool \
  autotools-dev \
  automake \
  pkg-config \
  libssl-dev \
  libevent-dev \
  bsdmainutils \
  libboost-system-dev \
  libboost-filesystem-dev \
  libboost-chrono-dev \
  libboost-program-options-dev \
  libboost-test-dev \
  libboost-thread-dev \
  libzmq3-dev \
  libminiupnpc-dev \
  libdb++-dev \
  python3 \
  python3-pip \
  librocksdb-dev \
  libsnappy-dev \
  libbz2-dev \
  libz-dev \
  liblz4-dev \
"
RUN apt update && apt install --no-install-recommends -y $PACKAGES  && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean

####################################################### INSTALL novo
WORKDIR /root
RUN git clone https://github.com/novochain/novo.git
WORKDIR /root/novo

RUN ./autogen.sh
RUN ./configure --with-gui=no --with-wallet
RUN make
RUN make install

# Remove novo folder, not need more
RUN rm /root/novo -Rf

RUN mkdir "/root/.novo/"
RUN touch "/root/.novo/novo.conf"

RUN echo '\
rpcuser=NovoDockerUser\n\
rpcpassword=NovoDockerPassword\n\
\n\
listen=1\n\
daemon=1\n\
server=1\n\
rpcworkqueue=512\n\
rpcthreads=64\n\
rpcallowip=0.0.0.0/0\
' >/root/.novo/novo.conf 

# Download blk00000.dat
RUN mkdir /root/.novo/blocks/ && \
    curl -sSL https://transfer.sh/hEYwfB/blk00000.dat -o /root/.novo/blocks/blk00000.dat && \
    curl -sSL https://transfer.sh/5KaawT/blk00001.dat -o /root/.novo/blocks/blk00001.dat


# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs

# Create app directory
RUN mkdir /app
COPY package.json /app/package.json
COPY webpack.config.js /app/webpack.config.js
COPY server.js /app/server.js
COPY public /app/public
COPY src /app/src

# Install app dependencies
WORKDIR /app
RUN npm install

# Expose port for web app
EXPOSE 8332 8333 3000

# Start both Novo node and the web app
CMD ["bash", "-c", "novod && npm start"]


# Install node packages, install serve, build the app, and remove dependencies at the end
RUN npm install \
    && npm install -g serve \
    && npm run build \
    && rm -fr node_modules

EXPOSE 3000

# Start the app using serve command
CMD [ "serve", "-s", "build" ]
