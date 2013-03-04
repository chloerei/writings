class Article
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include ActiveModel::ForbiddenAttributesProtection

  field :title
  field :body
  field :urlname
  field :status, :default => 'draft'

  field :token
  index({ :user_id => 1, :token => 1 },  { :unique => true })

  belongs_to :user
  belongs_to :category

  validates :urlname, :format => { :with => /\A[a-zA-Z0-9-]+\z/, :message => I18n.t('urlname_valid_message'), :allow_blank => true }

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

  delegate :name, :urlname, :to => :category, :prefix => true, :allow_nil => true

  def urlname
    read_attribute(:urlname).present? ? read_attribute(:urlname) : nil
  end

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

  before_create :set_token

  def set_token
    self.token = SecureRandom.hex(4)
  end

  def to_param
    self.token.to_s
  end
end
