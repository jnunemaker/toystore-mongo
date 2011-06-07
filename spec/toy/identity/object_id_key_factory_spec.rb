require 'helper'

describe Toy::Identity::ObjectIdKeyFactory do
  uses_constants('User')

  it "should use BSON::ObjectId as key_type" do
    Toy::Identity::ObjectIdKeyFactory.new.key_type.should be(BSON::ObjectId)
  end

  it "should use object id for next key" do
    key = Toy::Identity::ObjectIdKeyFactory.new.next_key(nil)
    key.should be_instance_of(BSON::ObjectId)
  end

  describe "Declaring key to be object_id" do
    before(:each) do
      User.key(Toy::Identity::ObjectIdKeyFactory.new)
      User.attribute(:name, String)
    end

    it "returns BSON::ObjectId as .key_type" do
      User.key_type.should be(BSON::ObjectId)
    end

    it "sets id attribute to BSON::ObjectId type" do
      User.attributes['id'].type.should be(BSON::ObjectId)
    end

    it "correctly stores id in database" do
      user = User.create(:name => 'John')
      user.id.should be_instance_of(BSON::ObjectId)
      key = user.store.client.find_one(user.id)['_id']
      key.should be_instance_of(BSON::ObjectId)
      user.id.should == key
    end
  end
end