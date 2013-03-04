class Category
  include Mongoid::Document
  include ActiveModel::ForbiddenAttributesProtection

  field :name
  field :description
  field :urlname

  has_many :articles, :dependent => :nullify
  belongs_to :user

  validates :name, :urlname, :presence => true
  validates :urlname, :uniqueness => { :scope => :user_id, :case_sensitive => false }, :format => { :with => /\A[a-zA-Z0-9-]+\z/, :message => I18n.t('urlname_valid_message') }

  def to_param
    urlname
  end
end
