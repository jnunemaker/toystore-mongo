require 'plucky'
require 'toy'
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

Toy.plugin(Toy::Mongo)
