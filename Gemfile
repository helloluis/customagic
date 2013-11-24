source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'
gem 'rake'
gem 'activeresource'

gem 'mongoid', '~> 4', :github => 'mongoid/mongoid'
gem 'mongoid_search'
gem 'mongoid_slug'
gem 'mongoid-sadstory' # https://github.com/mongoid/mongoid/issues/2954
gem 'mongoid_taggable'
gem 'mongoid_rating'
# gem 'mongoid_rails_migrations'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'
gem 'compass'
gem 'compass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

gem 'devise'
gem 'devise_invitable'
gem 'omniauth'
gem 'omniauth-facebook'

gem 'hashie'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'slim'

gem 'simple_form'
gem 'country_select'

gem 'kaminari'

gem 'simple_form'

gem 'fog'

gem 'fb_graph'

gem 'carrierwave'
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem 'mini_magick'

gem 'imgkit'
# after your bundle install, run this command (from your application root) 
# to install the actual binary that actually generates the images:
# rvmsudo imgkit --install-wkhtmltoimage

gem 'sanitize'

gem 'aws-ses', :require => 'aws/ses'

# redis related gems
gem 'redis'
gem 'redis-rails'
gem 'redis-store' #, "~> 1.1.0"
gem 'sidekiq' #, "~> 2.0.0"
# gem 'kiqstand'


# Use CoffeeScript for .js.coffee assets and views
# gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', :require => false
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
group :development do
  gem 'capistrano', "~> 2.15.0"
  gem 'rvm-capistrano'
  gem 'capistrano_colors'
  gem 'capistrano-ext'
  gem 'capistrano-nginx'
  gem 'capistrano-unicorn'
  gem 'capistrano-deploytags'
end

gem 'rails_12factor', group: :production

# Use debugger
# gem 'debugger', group: [:development, :test]

ruby "1.9.3"