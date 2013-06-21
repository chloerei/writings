class Category
  include Mongoid::Document
  include ActiveModel::ForbiddenAttributesProtection
  include SpaceToken

  field :name

  has_many :articles, :dependent => :nullify

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :space_id
end
