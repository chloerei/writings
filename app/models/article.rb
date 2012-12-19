class Article
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include ActiveModel::ForbiddenAttributesProtection

  field :title
  field :body
  field :urlname
  field :publish, :type => Boolean, :default => false

  belongs_to :user
  belongs_to :book

  validates :urlname, :presence => true, :uniqueness => { :scope => :book_id, :case_sensitive => false }

  scope :publish, where(:publish => true)
  scope :draft, where(:publish => false)

  after_initialize do |article|
      article.urlname ||= article.id.to_s
  end

  def title
    read_attribute(:title).blank? ? 'untitle' : read_attribute(:title)
  end
end
