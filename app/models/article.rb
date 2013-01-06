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

  scope :publish, where(:publish => true)
  scope :draft, where(:publish => false)
  scope :status, -> status {
    case status
    when 'publish'
      where(:publish => true)
    when 'draft'
      where(:publish => false)
    else
      scoped
    end
  }

  def title
    read_attribute(:title).blank? ? 'untitle' : read_attribute(:title)
  end
end
