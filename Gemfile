source "https://rubygems.org"

gem "rails", "~> 8.1.3"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", "~> 8.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

gem "devise"
gem "tailwindcss-rails", "~> 4.6"
gem "pdf-reader", "~> 2.12"
gem "docx", "~> 0.9"
gem "pagy", "~> 9.0"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "rails-controller-testing"
  gem "shoulda-matchers"
end
