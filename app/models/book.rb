class Book
  include Mongoid::Document
  include ActiveModel::ForbiddenAttributesProtection

  field :name
  field :description
  field :urlname

  has_many :articles, :dependent => :nullify
  belongs_to :user

  validates :name, :urlname, :presence => true
  validates :urlname, :uniqueness => { :scope => :user_id, :case_sensitive => false }

  def to_param
    urlname
  end
end
