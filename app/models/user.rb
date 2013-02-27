class User
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include ActiveModel::SecurePassword
  include ActiveModel::ForbiddenAttributesProtection
  include Gravtastic

  gravtastic :filetype => :png, :size => 100

  field :name
  field :email
  field :password_digest
  field :access_token
  field :locale, :default => I18n.locale.to_s
  field :domain
  field :disqus_shortname

  embeds_one :profile

  has_many :categories, :dependent => :delete
  has_many :articles, :dependent => :delete

  has_secure_password

  validates :name, :email, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :name, :format => {:with => /\A\w+\z/, :message => 'only A-Z, a-z, _ allowed'}, :length => {:in => 3..20}
  validates :email, :format => {:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/}
  validates :password, :password_confirmation, :presence => true, :on => :create
  validates :password, :length => {:minimum => 6, :allow_blank => true}
  validates :locale, :inclusion => {:in => ALLOW_LOCALE}
  validates :current_password, :presence => true, :on => :update
  validates :domain, :format => {:with => /(\w+\.)+\w+/}, :uniqueness => {:case_sensitive => false}, :allow_blank => true

  attr_accessor :current_password

  before_create :build_profile

  def check_current_password(password)
    if authenticate(password)
      true
    else
      errors.add(:current_password, "is not match")
      false
    end
  end

  def remember_token
    [id, Digest::SHA512.hexdigest(password_digest)].join('$')
  end

  def self.find_by_remember_token(token)
    user = first :conditions => {:_id => token.split('$').first}
    (user && user.remember_token == token) ? user : nil
  end

  def set_access_token
    self.access_token ||= generate_token
  end

  def generate_token
    SecureRandom.hex(32)
  end

  def reset_access_token
    update_attribute :access_token, generate_token
  end

  def self.find_by_access_token(token)
    first :conditions => {:access_token => token} if token.present?
  end

  def admin?
    APP_CONFIG['admin_emails'].include?(self.email)
  end

  def host
    domain.present? ? domain : "#{name}.#{APP_CONFIG['host']}"
  end

  def display_name
    profile.name.present? ? profile.name : name
  end
end
