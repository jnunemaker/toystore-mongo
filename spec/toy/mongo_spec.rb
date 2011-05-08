require 'helper'

describe Toy::Mongo do
  it "defaults key factory to object_id" do
    klass = Class.new do
      include Toy::Store
    end
    klass.key_factory.should be_instance_of(Toy::Identity::ObjectIdKeyFactory)
  end
end