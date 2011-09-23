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
      include Toy::Store
      include Querying

      key(Toy::Identity::ObjectIdKeyFactory.new)
    end
  end
end
