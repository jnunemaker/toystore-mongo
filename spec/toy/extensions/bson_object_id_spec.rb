require 'helper'

describe "BSON::ObjectId.to_store" do
  it "returns nil if value nil" do
    BSON::ObjectId.to_store(nil).should be_nil
  end

  it "returns value if already bson object id" do
    id = BSON::ObjectId.new
    BSON::ObjectId.to_store(id).should be(id)
  end

  it "returns bson object id if string and valid bson object id" do
    id = BSON::ObjectId.new
    BSON::ObjectId.to_store(id.to_s).should == id
  end
  
  it "returns whatever is passed in if not object id or string version of object id" do
    BSON::ObjectId.to_store('foo').should == 'foo'
  end
end

describe "BSON::ObjectId.from_store" do
  it "returns nil if value nil" do
    BSON::ObjectId.from_store(nil).should be_nil
  end

  it "returns value if already bson object id" do
    id = BSON::ObjectId.new
    BSON::ObjectId.from_store(id).should be(id)
  end

  it "returns bson object id if string and valid bson object id" do
    id = BSON::ObjectId.new
    BSON::ObjectId.from_store(id.to_s).should == id
  end
  
  it "returns whatever is passed in if not object id or string version of object id" do
    BSON::ObjectId.from_store('foo').should == 'foo'
  end
end
