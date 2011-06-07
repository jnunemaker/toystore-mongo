require 'plucky'
require 'toy'
require 'toy/extensions/bson_object_id'
require 'toy/identity/object_id_key_factory'
require 'toy/mongo/querying'
require 'adapter/mongo'

module Toy
  module Mongo
    extend ActiveSupport::Concern

    included do
      include Querying
    end
  end
end

Toy.key_factory = Toy::Identity::ObjectIdKeyFactory.new
Toy.plugin(Toy::Mongo)
