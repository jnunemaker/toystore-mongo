# Toystore Mongo

Mongo integration for Toystore.

## Install

```
gem install toystore-mongo
```

## Usage

```ruby
class User
  include Toy::Mongo
  adapter :mongo, Mongo::Connection.new.db('myapp')['users']

  attribute :name, String
end
```

Including Toy::Mongo includes Toy::Store and then does a few things:

* Includes Plucky querying so you can do things like User.count, User.all, User.first, and much more
* Sets the key factory to object id
* Overrides get so that it also works with string representation of object id
* Overrides get_multi so that it performs one query instead of one query per id


### Atomic Updates

```ruby
class User
  include Toy::Mongo
  include Toy::Mongo::AtomicUpdates

  adapter :mongo_atomic, Mongo::Connection.new.db('adapter')['testing']

  attribute :name, String
  attribute :bio, String
end

user = User.create(:name => 'John', :bio => 'Awesome!')
user.name = 'Nunes'
user.save # Equivalent to update({:_id => user.id}, {'$set' => {'name' => 'Nunes'}})
```

Caveat: At this time it only works with simple data types. Complex types like Hash, Array, and Set are not supported. Oddness will ensue if you expect them to work as they can be manipuled through means other than assignment.

## Contributing

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

See LICENSE for details.
