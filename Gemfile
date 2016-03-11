source 'https://rubygems.org'
ruby '2.3.0'
gem 'rails', '4.2.5.2'
gem 'sqlite3'
gem 'bootstrap-sass'
gem 'coffee-rails', '~> 4.1.0'
gem 'devise'
gem 'gibbon', '~> 2.2', '>= 2.2.1'
gem 'high_voltage'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'payola-payments'
gem 'sass-rails', '~> 5.0'
gem 'stripe'
gem 'stripe_event'
gem 'sucker_punch'
gem 'uglifier', '>= 1.3.0'
group :development do
  gem 'better_errors'
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'spring-commands-rspec'
  gem 'web-console', '~> 3.0'
end
group :development, :test do
  gem 'byebug'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'spring'
  # gem 'stripe-ruby-mock', '~> 2.2.2', require: 'stripe_mock'
  gem 'stripe-ruby-mock', git: 'https://github.com/rebelidealist/stripe-ruby-mock.git', branch: 'master', require: 'stripe_mock'
  gem 'thin', '~> 1.6.3'
end
group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
end
