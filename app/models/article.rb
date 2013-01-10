class Article
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include ActiveModel::ForbiddenAttributesProtection

  field :title
  field :body
  field :urlname
  field :status, :default => 'draft'

  field :number_id, :type => Integer
  index({ :user_id => 1, :number_id => 1 },  { :unique => true })

  belongs_to :user
  belongs_to :book

  scope :publish, -> { where(:status => 'publish') }
  scope :draft, -> { where(:status => 'draft') }
  scope :trash, -> { where(:status => 'trash') }

  scope :status, -> status {
    case status
    when 'publish'
      publish
    when 'draft'
      draft
    when 'trash'
      trash
    else
      where(:status.ne => 'trash')
    end
  }

  delegate :name, :urlname, :to => :book, :prefix => true, :allow_nil => true

  def publish?
    self.status == 'publish'
  end

  def draft?
    self.status == 'draft'
  end

  def trash?
    self.status == 'trash'
  end

  def title
    read_attribute(:title).blank? ? 'Untitle' : read_attribute(:title)
  end

  before_create :set_number_id

  def set_number_id
    self.number_id = user.inc(:next_topic_id, 1)
  end

  def to_param
    self.number_id.to_s
  end
end
