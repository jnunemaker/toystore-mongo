source "http://rubygems.org"
gemspec

gem 'rake', '~> 0.9.0'

# keep mongo and bson ext at same version
gem 'mongo', '~> 1.6.0'
gem 'bson_ext', '~> 1.6.0', :require => false

group(:guard) do
  gem 'guard',          '~> 1.0.0'
  gem 'guard-rspec',    '~> 0.6.0'
  gem 'guard-bundler',  '~> 0.1.0'
  gem 'growl',          '~> 1.0.0'
end

group(:test) do
  gem 'rspec', '~> 2.8'
end
