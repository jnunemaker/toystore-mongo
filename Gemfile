source "http://rubygems.org"
gemspec

gem 'rake'
gem 'bson_ext', :require => false

group(:guard) do
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-bundler'
end

group(:test) do
  gem 'rspec',      '~> 2.3'
  gem 'log_buddy',  '~> 0.5.0'
end
