class Category
  include Mongoid::Document
  include ActiveModel::ForbiddenAttributesProtection

  field :name
  field :token, :type => Integer

  index({ :space_id => 1, :token => 1 }, { :unique => true })

  has_many :articles, :dependent => :nullify
  belongs_to :space

  validates_presence_of :name
  validates_uniqueness_of :name

  before_create :set_token

  def set_token
    self.token ||= space.inc(:category_next_id, 1)
  end

  def to_param
    token.to_s
  end
end
