source 'http://rubygems.org'

gem 'rails', '3.2.8'
gem 'jquery-rails'
gem 'rake'
gem 'haml'
gem "formtastic", "~> 2.0.2"
gem "activeadmin", "~> 0.4.3"
gem 'meta_search', '>= 1.1.0.pre'
gem 'sass-rails'

gem 'validates_timeliness'
gem 'cancan'
gem 'prawn_rails'
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'fastercsv'
#gem 'rspec-rails', :group => [:development, :test]
gem 'rails3-jquery-autocomplete'
gem 'ruby-units'
gem 'breadcrumbs_on_rails'
gem 'newrelic_rpm'
gem "rack-timeout"
gem "heroku"

group :production, :staging do
  gem "pg"
end

group :development do
  gem 'taps'
  gem 'faker', '0.3.1'
  gem 'sqlite3', :require => 'sqlite3'
  gem 'annotate', ">=2.5.0"
end

group :test do
  gem 'rspec-rails'
  gem 'spork-rails', '3.2.0'
  #gem 'webrat'
  gem 'factory_girl_rails', "~> 4.0"
  gem "capybara"
  gem "guard-rspec"
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  #gem 'sqlite3-ruby', :require => 'sqlite3'
end