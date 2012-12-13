class Article
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include ActiveModel::ForbiddenAttributesProtection

  field :title
  field :body
  field :urlname

  belongs_to :user
  belongs_to :book

  validates :title, :body, :presence => true
  validates :urlname, :presence => true, :uniqueness => { :scope => :book_id, :case_sensitive => false }

  after_initialize do |article|
    article.urlname ||= article.id.to_s
  end
end
