class Book
  include Mongoid::Document

  field :name
  field :urlname

  belongs_to :user

  validates :name, :urlname, :presence => true
  validates :urlname, :uniqueness => { :scope => :user_id, :case_sensitive => false }
end
