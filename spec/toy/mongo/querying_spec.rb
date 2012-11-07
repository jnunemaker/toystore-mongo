require 'helper'

describe Toy::Mongo::Querying do
  uses_constants 'User'

  before(:each) do
    User.attribute :name, String
    User.attribute :bio, String
  end

  describe "#query" do
    it "returns a plucky query instance" do
      User.query.should be_instance_of(Plucky::Query)
    end
  end

  Toy::Mongo::Querying::PluckyMethods.each do |name|
    it "delegates ##{name} to #query" do
      query = User.query
      query.should_receive(name)
      User.should_receive(:query).and_return(query)
      User.send(name)
    end
  end

  describe "#get" do
    before(:each) do
      @user = User.create
    end

    it "works for string object id" do
      User.get(@user.id.to_s).should == @user
    end

    it "works for object id" do
      User.get(@user.id).should == @user
    end

    it "returns nil for invalid object id" do
      User.get('1234').should be_nil
    end
  end
end
