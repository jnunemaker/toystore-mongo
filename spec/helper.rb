$:.unshift(File.expand_path('../../lib', __FILE__))

require 'pathname'
require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

require 'toy/mongo'
require 'support/constants'
require 'support/callbacks_helper'

STORE = Mongo::MongoClient.new.db('testing')["toystore-mongo-#{RUBY_VERSION}"]

RSpec.configure do |c|
  c.include(Support::Constants)

  c.before(:each) do
    STORE.remove
  end
end
