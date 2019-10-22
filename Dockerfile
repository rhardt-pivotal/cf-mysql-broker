FROM ruby:2.6.5
RUN apt-get update && apt-get install -y --force-yes mariadb-client && mkdir -p /myapp && useradd -ms /bin/bash cfm && chown cfm /myapp
USER cfm
WORKDIR /myapp
RUN gem install bundler
COPY Gemfile /myapp
COPY Gemfile.lock /myapp
# RUN bundle install
COPY Rakefile /myapp
COPY config.ru /myapp
COPY app /myapp
COPY config /myapp
COPY db /myapp
COPY lib /myapp

RUN bash -l -c 'BUNDLE_WITHOUT=development:test bundle package --all --all-platforms --no-install --path ./vendor/cache'
RUN bash -l -c 'bundle install --local --deployment --without development test'



