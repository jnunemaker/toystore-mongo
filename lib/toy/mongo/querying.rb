module Toy
  module Mongo
    module Querying
      extend ActiveSupport::Concern

      PluckyMethods = [
        :where, :filter, :limit, :skip, :offset, :sort, :order,
        :fields, :ignore, :only,
        :each, :find_each,
        :count, :size, :distinct,
        :last, :first, :all, :paginate,
        :exists?, :exist?, :empty?,
        :to_a, :remove,
      ]

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

        # Mongo does not guarantee sort order when using $in.
        # So we manually sort in ruby for now. Not stoked about
        # this, but it gets the job done.
        def get_multi(*ids)
          ids  = ids.flatten
          all(:_id => {'$in' => ids}).sort do |a, b|
            index_a = ids.index(a.id)
            index_b = ids.index(b.id)
            if index_a.nil? || index_b.nil?
              1
            else
              index_a <=> index_b
            end
          end
        end

        def query
          # TODO: add object id keys to convert
          Plucky::Query.new(store.client, :transformer => transformer).object_ids(object_id_attributes)
        end

        PluckyMethods.each do |name|
          define_method(name) do |*args|
            query.send(name, *args)
          end
        end
      end

      # Very basic method for determining what has changed locally
      # so we can just update changes instead of entire document
      #
      # Does not work with complex objects (array, hash, set, etc.)
      # as it does not attempt to determine what has changed in them,
      # just whether or not they have changed at all.
      def persistable_changes
        attrs = {}
        pattrs = persisted_attributes
        changed.each do |key|
          attribute = self.class.attributes[key.to_s]
          next if attribute.virtual?
          attrs[attribute.persisted_name] = pattrs[attribute.persisted_name]
        end
        attrs
      end

      def atomic_update_attributes(attrs={})
        self.attributes = attrs
        if valid?
          atomic_update('$set' => persistable_changes)
          true
        else
          false
        end
      end

      def atomic_update(update, opts={})
        options  = {}
        criteria = {'_id' => id}
        criteria.update(opts[:criteria]) if opts[:criteria]
        options[:safe] = opts.key?(:safe) ? opts[:safe] : store.options[:safe]
        store.client.update(criteria, update, options)
      end
    end
  end
end