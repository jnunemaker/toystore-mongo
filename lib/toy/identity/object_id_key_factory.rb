module Toy
  module Identity
    class ObjectIdKeyFactory < AbstractKeyFactory
      def key_type
        BSON::ObjectId
      end

      def next_key(object)
        BSON::ObjectId.new
      end
    end
  end
end
