require 'plucky'
require 'toy'
require 'toy/extensions/bson_object_id'
require 'toy/identity/object_id_key_factory'
require 'toy/mongo/querying'
require 'toy/mongo/atomic_updates'
require 'adapter/mongo'

module Toy
  module Mongo
    extend ActiveSupport::Concern
    include Toy::Store
    include Querying

    class Error < StandardError; end

    included do
      key Toy::Identity::ObjectIdKeyFactory.new
    end
  end
end
