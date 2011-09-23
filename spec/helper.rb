$:.unshift(File.expand_path('../../lib', __FILE__))

require 'pathname'
require 'logger'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
log_path  = root_path.join('log')
log_path.mkpath

require 'rubygems'
require 'bundler'

Bundler.require(:development)

require 'toy/mongo'
require 'support/constants'
require 'support/callbacks_helper'

STORE = Mongo::Connection.new.db('testing')['toystore-mongo']

Logger.new(log_path.join('test.log')).tap do |log|
  LogBuddy.init(:logger => log)
  Toy.logger = log
end

RSpec.configure do |c|
  c.include(Support::Constants)

  c.before(:each) do
    STORE.remove
  end
end