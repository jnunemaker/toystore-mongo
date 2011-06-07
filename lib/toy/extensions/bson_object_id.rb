class BSON::ObjectId
  def self.to_store(value, *)
    Plucky.to_object_id(value)
  end

  def self.from_store(value, *args)
    Plucky.to_object_id(value)
  end
end
