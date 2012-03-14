module ObjectIdConversions
  def to_store(value, *)
    Plucky.to_object_id(value)
  end

  def from_store(value, *)
    Plucky.to_object_id(value)
  end
end

class BSON::ObjectId
  extend ObjectIdConversions
end
