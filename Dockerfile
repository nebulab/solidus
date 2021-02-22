ARG RUBY_VERSION=2.7.2

FROM ruby:$RUBY_VERSION

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && \
    apt-get install -y nodejs yarn chromium chromium-driver

ENV APP_USER=solidus_user \
    LANG=C.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3
ENV GEM_HOME=/home/$APP_USER/gems
ENV APP_HOME=/home/$APP_USER/app

RUN useradd -ms /bin/bash $APP_USER
USER $APP_USER

RUN gem install bundler

WORKDIR /home/$APP_USER/app
