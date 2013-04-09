class Article
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::ForbiddenAttributesProtection

  field :title
  field :body
  field :urlname
  field :status, :default => 'draft'
  field :save_count, :type => Integer, :default => 0
  field :published_at

  field :token
  index({ :user_id => 1, :token => 1 },  { :unique => true })
  index({ :user_id => 1, :urlname => 1 },  { :unique => true })

  belongs_to :user
  belongs_to :category

  validates :urlname, :format => { :with => /\A[a-zA-Z0-9-]+\z/, :message => I18n.t('urlname_valid_message') },:uniqueness => { :scope => :user_id, :case_sensitive => false }

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

  before_save :set_published_at

  def set_published_at
    if status_changed? && publish?
      self.published_at = Time.now.utc
    end
  end

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
    read_attribute(:title).blank? ? I18n.t(:untitled) : read_attribute(:title)
  end

  after_initialize :set_token

  def set_token
    if self.new_record?
      self.urlname = self.token = SecureRandom.hex(4)
    end
  end

  def to_param
    self.token.to_s
  end
end
