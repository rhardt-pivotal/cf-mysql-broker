source 'https://rubygems.org'

ruby '~> 2.6'

gem 'rails', '~> 6.0'
gem 'jquery-rails'
gem 'settingslogic'
gem 'mysql2'
# gem 'omniauth-uaa-oauth2', git: 'https://github.com/cloudfoundry/omniauth-uaa-oauth2'
gem 'nats'
gem 'sass-rails'
gem 'eventmachine'
gem 'rake'

group :production do
  gem 'unicorn'
end

group :development, :test do
  gem 'test-unit'
  gem 'rspec-rails', '~> 4.0.0.beta2'
  gem 'database_cleaner'
  gem 'brakeman'
  gem 'pry'
  gem 'rb-readline'
  gem 'rails-controller-testing'
end

group :test do
  gem 'codeclimate-test-reporter', '~> 0.6.0', require: nil
  gem 'webmock'
end
