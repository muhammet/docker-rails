FROM ruby:2.6.3

# Define locale
ENV LANG C.UTF-8

# Configure bundler
RUN \
  bundle config --global frozen 1 && \
  bundle config --global build.nokogiri --use-system-libraries 

# Install cmake
ENV CMAKE_MAJOR=3.4
ENV CMAKE_VERSION=3.4.3
ENV CMAKE_SHASUM256=66b8d315c852908be9f79e1a18b8778714659fce4ddb2d041af8680a239202fc
RUN \
  cd /usr/local && \
  curl -sfLO https://cmake.org/files/v$CMAKE_MAJOR/cmake-$CMAKE_VERSION-Linux-x86_64.tar.gz && \
  echo "${CMAKE_SHASUM256}  cmake-$CMAKE_VERSION-Linux-x86_64.tar.gz" | sha256sum -c - &&\
  tar --strip-components 1 -xzf cmake-$CMAKE_VERSION-Linux-x86_64.tar.gz cmake-$CMAKE_VERSION-Linux-x86_64/bin/cmake cmake-$CMAKE_VERSION-Linux-x86_64/share/cmake-$CMAKE_MAJOR/Modules cmake-$CMAKE_VERSION-Linux-x86_64/share/cmake-$CMAKE_MAJOR/Templates && \
  rm cmake-$CMAKE_VERSION-Linux-x86_64.tar.gz

RUN sed -i '/jessie-updates/d' /etc/apt/sources.list
# Install libssh2 from source
RUN apt-get update && \
    apt-get install -y git libssh2-1 libssh2-1-dev

# Install node.js
ENV NODE_VERSION=10.12.0

ENV NODE_SHASUM256=8d13d57aaf95177e97d29c0944d79a17de8c3a31ba3fe88d1846cfd907e52111
RUN \
  cd /usr/local && \
  curl -sfLO https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz && \
  echo "${NODE_SHASUM256}  node-v$NODE_VERSION-linux-x64.tar.gz" | sha256sum -c - &&\
  tar --strip-components 1 -xzf node-v$NODE_VERSION-linux-x64.tar.gz node-v$NODE_VERSION-linux-x64/bin node-v$NODE_VERSION-linux-x64/include node-v$NODE_VERSION-linux-x64/lib && \
  rm node-v$NODE_VERSION-linux-x64.tar.gz && \
  curl -sL https://deb.nodesource.com/setup_10.x &&\
  apt-get install -y nodejs

# Install yarn
RUN apt-get update && apt-get install -y apt-transport-https
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -\
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn

# Set the working directory
ONBUILD RUN mkdir -p /usr/src/app
ONBUILD WORKDIR /usr/src/app

# Copy dependency spec files
ONBUILD COPY package.json* yarn.lock* .npmrc* Gemfile* /usr/src/app/

# Install NPMs
ONBUILD RUN if [ -f package.json ]; then \
    yarn install || { echo "\033[0;31mMake sure you have run 'npm login' and have an ~/.npmrc file" && exit 1; }; \
    rm -f .npmrc; \
    fi;

# Install libgit2 for pronto gem
RUN apt-get install -y wget
RUN git clone https://github.com/libgit2/libgit2.git
RUN cd libgit2 && mkdir build && cd build && cmake .. && cmake --build .

# Install gems
ONBUILD COPY vendor /usr/src/app/vendor
ONBUILD RUN bundle install --local --jobs `nproc`

# Copy the rest of the application source
ONBUILD COPY . /usr/src/app

# Run the requirejs optimizer if the badcom gem is included and precompile assets.
ONBUILD RUN \
  ! gem list -i badcom > /dev/null || RAILS_ENV=production RAILS_ASSETS_COMPILE=true rake badcom:requirejs:optimize_all && \
  RAILS_ENV=production RAILS_ASSETS_COMPILE=true rake assets:precompile

# Run the server
ONBUILD EXPOSE 3000
ONBUILD CMD ["puma", "-t", "8:8", "-p", "3000"]
