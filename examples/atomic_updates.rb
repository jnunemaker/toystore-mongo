require 'pathname'
require 'rubygems'
require 'bundler'

Bundler.require(:default)

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)

require 'toy/mongo'

class User
  include Toy::Mongo
  include Toy::Mongo::AtomicUpdates

  adapter :mongo_atomic, Mongo::Connection.new.db('adapter')['testing']

  attribute :name, String
  attribute :bio, String
end

user = User.create(:name => 'John', :bio => 'Awesome!')
puts user.name # John
puts user.bio  # Awesome!

# simulate another process updating only bio
user.adapter.client.update({:_id => user.id}, '$set' => {:bio => "Changed!"})

user.name = 'Nunes'
user.save # save performs update with $set's rather than full doc save

user.reload

puts user.name # Nunes
puts user.bio  # Changed!
