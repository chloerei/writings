class Profile
  include Mongoid::Document

  field :name
  field :description

  embedded_in :user
end
