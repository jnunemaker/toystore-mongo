module Support
  module Constants
    extend ActiveSupport::Concern

    module ClassMethods
      def uses_constants(*constants)
        before { create_constants *constants }
        after  { remove_constants *constants }
      end
    end

    def create_constants(*constants)
      constants.each { |constant| create_constant constant }
    end

    def remove_constants(*constants)
      constants.each { |constant| remove_constant constant }
    end

    def create_constant(constant, superclass=nil)
      Object.const_set constant, Model(superclass)
    end

    def remove_constant(constant)
      if Object.const_defined?(constant)
        Object.send :remove_const, constant
      end
    end

    def Model(superclass=nil)
      if superclass.nil?
        Class.new {
          include Toy::Mongo
          adapter :mongo, STORE
        }
      else
        Class.new(superclass) {
          include Toy::Mongo
          adapter :mongo, STORE
        }
      end
    end
  end
end
