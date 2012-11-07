module Toy
  module Mongo
    module Querying
      extend ActiveSupport::Concern

      PluckyMethods = Plucky::Methods

      module ClassMethods
        def transformer
          @transformer ||= lambda do |doc|
            load(doc.delete('_id'), doc)
          end
        end

        def object_id_attributes
          attributes.values.select do |attribute|
            attribute.type == BSON::ObjectId
          end.map do |attribute|
            sym = attribute.name.to_sym
            sym == :id ? :_id : sym
          end
        end

        def get(id)
          super Plucky.to_object_id(id)
        end

        def query
          Plucky::Query.new(adapter.client, :transformer => transformer).object_ids(object_id_attributes)
        end

        PluckyMethods.each do |name|
          define_method(name) do |*args|
            query.send(name, *args)
          end
        end
      end
    end
  end
end
