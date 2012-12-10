class Book
  include Mongoid::Document

  field :name
  field :urlname

  belongs_to :user
end
