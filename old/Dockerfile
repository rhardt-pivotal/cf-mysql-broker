FROM rhardt/ruby-base

RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
# RUN bundle install
COPY Rakefile /myapp
COPY config.ru /myapp
COPY app /myapp
COPY config /myapp
COPY db /myapp
COPY lib /myapp

RUN bash -l -c 'BUNDLE_WITHOUT=development:test bundle package --all --all-platforms --no-install --path ./vendor/cache'
RUN bash -l -c 'bundle install --local --deployment --without development test'


