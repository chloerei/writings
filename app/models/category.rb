class Category
  include Mongoid::Document
  include ActiveModel::ForbiddenAttributesProtection
  include SpaceToken

  field :name

  has_many :articles, :dependent => :nullify

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :space_id

  after_save do
    space.touch
  end

  def to_param
    if name.parameterize.present?
      "#{token}-#{name.parameterize}"
    else
      token
    end
  end
end
