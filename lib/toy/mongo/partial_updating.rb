module Toy
  module Mongo
    class IncompatibleAdapter < Error
      def initialize(name)
        super "In order to use partial updates, you need to be using the :mongo_atomic adapter, but you are using :#{name}"
      end
    end

    module PartialUpdating
      extend ActiveSupport::Concern

      included do
        class_attribute :partial_updates

        self.partial_updates = false
      end

      module ClassMethods
        def use_partial_updates
          if adapter.name != :mongo_atomic
            raise IncompatibleAdapter.new(adapter.name)
          end

          self.partial_updates = true
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

      def persist
        if partial_updates?
          if new_record?
            adapter.write id, persisted_attributes
          else
            updates = persistable_changes
            if updates.present?
              adapter.write id, updates
            end
          end
        else
          super
        end
      end

      def atomic_update(update, opts={})
        options  = {}
        criteria = {:_id => id}
        criteria.update(opts[:criteria]) if opts[:criteria]
        options[:safe] = opts.key?(:safe) ? opts[:safe] : adapter.options[:safe]

        run_callbacks(:save) do
          run_callbacks(:update) do
            adapter.client.update(criteria, update, options)
          end
        end
      end
    end
  end
end
