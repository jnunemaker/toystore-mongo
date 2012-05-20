require 'helper'

describe Toy::Mongo::PartialUpdating do
  uses_constants 'User'

  describe "#persistable_changes" do
    before(:each) do
      User.attribute :name, String
      User.attribute :bio, String
      User.attribute(:password, String, :virtual => true)
      User.attribute(:email, String, :abbr => :e)
      @user = User.create(:name => 'John', :password => 'secret', :email => 'nunemaker@gmail.com')
    end

    it "returns only changed attributes" do
      @user.name = 'Frank'
      @user.persistable_changes.should == {'name' => 'Frank'}
    end

    it "returns typecast values" do
      @user.name = 1234
      @user.persistable_changes.should == {'name' => '1234'}
    end

    it "ignores virtual attributes" do
      @user.password = 'ignore me'
      @user.persistable_changes.should be_empty
    end

    it "uses abbreviated key" do
      @user.email = 'john@orderedlist.com'
      @user.persistable_changes.should == {'e' => 'john@orderedlist.com'}
    end
  end

  describe "#atomic_update" do
    before(:each) do
      User.send :include, CallbacksHelper
      User.attribute :name, String
      @user = User.create(:name => 'John')
    end

    it "performs update" do
      @user.atomic_update('$set' => {'name' => 'Frank'})
      @user.reload
      @user.name.should == 'Frank'
    end

    it "defaults to adapter's :safe option" do
      @user.adapter.client.should_receive(:update).with(kind_of(Hash), kind_of(Hash), :safe => nil)
      @user.atomic_update('$set' => {'name' => 'Frank'})

      User.adapter(:mongo, STORE, :safe => false)
      @user.adapter.client.should_receive(:update).with(kind_of(Hash), kind_of(Hash), :safe => false)
      @user.atomic_update('$set' => {'name' => 'Frank'})

      User.adapter(:mongo, STORE, :safe => true)
      @user.adapter.client.should_receive(:update).with(kind_of(Hash), kind_of(Hash), :safe => true)
      @user.atomic_update('$set' => {'name' => 'Frank'})
    end

    it "runs callbacks in correct order" do
      doc = User.create.tap(&:clear_history)
      doc.atomic_update({})
      doc.history.should == [:before_save, :before_update, :after_update, :after_save]
    end

    context "with :safe option" do
      it "overrides adapter's :safe option" do
        User.adapter(:mongo, STORE, :safe => false)
        @user.adapter.client.should_receive(:update).with(kind_of(Hash), kind_of(Hash), :safe => true)
        @user.atomic_update({'$set' => {'name' => 'Frank'}}, :safe => true)

        User.adapter(:mongo, STORE, :safe => true)
        @user.adapter.client.should_receive(:update).with(kind_of(Hash), kind_of(Hash), :safe => false)
        @user.atomic_update({'$set' => {'name' => 'Frank'}}, :safe => false)
      end
    end

    context "with :criteria option" do
      uses_constants('Site')

      it "allows updating embedded documents using $ positional operator" do
        User.attribute(:sites, Array)
        site1 = Site.create
        site2 = Site.create
        @user.update_attributes(:sites => [{'id' => site1.id, 'ui' => 1}, {'id' => site2.id, 'ui' => 2}])

        @user.atomic_update(
          {'$set' => {'sites.$.ui' => 2}},
          {:criteria => {'sites.id' => site1.id}}
        )
        @user.reload
        @user.sites.map { |s| s['ui'] }.should == [2, 2]
      end
    end
  end

  describe ".partial_updates" do
    it "defaults to false" do
      User.partial_updates.should be_false
    end

    it "can be turned on" do
      User.partial_updates = true
      User.partial_updates.should be_true
    end

    it "is inherited" do
      User.partial_updates = true
      subclass = Class.new(User)
      subclass.partial_updates.should be_true
    end

    it "is inherited separate from superclass" do
      User.partial_updates = true
      subclass = Class.new(User)
      subclass.partial_updates = false
      User.partial_updates.should be_true
      subclass.partial_updates.should be_false
    end
  end

  describe "#persist" do
    context "with partial updates on" do
      before do
        User.adapter :mongo_atomic, STORE
        User.partial_updates = true
      end

      it "only persists changes" do
        User.attribute :name, String
        User.attribute :bio, String

        user = User.create(:name => 'John', :bio => 'Awesome.')
        user.name = 'Johnny'

        # simulate outside change
        user.adapter.client.update({:_id => user.id}, {'$set' => {:bio => 'Surprise!'}})

        user.save
        user.reload

        user.name.should eq('Johnny')
        user.bio.should eq('Surprise!')
      end

      it "persists default values that did not change" do
        User.attribute :version, Integer, :default => 1
        user = User.new
        user.adapter.should_receive(:write).with(user.id, {
          'version' => 1,
        })
        user.save
      end

      it "does not persist virtual attributes" do
        User.attribute :name, String
        User.attribute :password, String, :virtual => true

        user = User.new(:name => 'John')
        user.password = 'hacks'
        user.adapter.should_receive(:write).with(user.id, {
          'name' => 'John',
        })
        user.save
      end

      it "does persist new records even without changes" do
        user = User.create
        user.persisted?.should be_true
      end

      it "does not persist if there were no changes" do
        user = User.create
        user.adapter.should_not_receive(:write)
        user.save
      end

      it "works with abbreviated attributes" do
        User.attribute :email, String, :abbr => :e
        user = User.new(:email => 'john@doe.com')
        user.adapter.should_receive(:write).with(user.id, {
          'e' => 'john@doe.com',
        })
        user.save
      end
    end

    context "with partial updates off" do
      before do
        User.attribute :name, String
        User.attribute :bio, String
        User.partial_updates = false
      end

      it "persists entire document blowing away outside changes" do
        user = User.create(:name => 'John', :bio => 'Awesome.')
        user.name = 'Johnny'

        # simulate outside change
        user.adapter.client.update({:_id => user.id}, {'$set' => {:bio => 'Surprise!'}})

        user.save
        user.reload

        user.name.should eq('Johnny')
        user.bio.should eq('Awesome.')
      end
    end
  end
end
