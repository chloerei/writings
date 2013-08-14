class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::ForbiddenAttributesProtection
  include ActiveModel::SecurePassword
  include Gravtastic

  gravtastic :filetype => :png, :size => 100

  field :name
  field :full_name
  field :description
  field :email
  field :password_digest
  field :password_reset_token
  field :password_reset_token_created_at, :type => Time
  field :locale, :default => I18n.locale.to_s

  has_many :spaces, :dependent => :destroy

  has_secure_password

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, :format => {:with => /\A[a-z0-9-]+\z/, :message => I18n.t('errors.messages.space_name') }, :length => {:in => 4..20}
  validates :email, :presence => true, :uniqueness => {:case_sensitive => false}, :format => {:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/}
  validates :password, :length => { :minimum => 6 }, :on => :create
  validates :locale, :inclusion => {:in => ALLOW_LOCALE}
  validates :current_password, :presence => true, :if => :need_current_password
  validates_length_of :password, :minimum => 6, :if => :in_password_reset

  attr_accessor :current_password, :need_current_password, :in_password_reset

  def member_spaces
    Space.where(:member_ids => self.id)
  end

  def remember_token
    [id, Digest::SHA512.hexdigest(password_digest)].join('$')
  end

  def self.find_by_remember_token(token)
    user = where(:_id => token.split('$').first).first
    (user && user.remember_token == token) ? user : nil
  end

  def generate_password_reset_token
    update_attributes(
      :password_reset_token => generate_token,
      :password_reset_token_created_at => Time.now.utc
    )
  end

  def unset_password_reset_token
    unset(:password_reset_token, :password_reset_token_created_at)
  end

  def generate_token
    SecureRandom.hex(32)
  end

  def admin?
    APP_CONFIG['admin_emails'].include?(self.email)
  end

  def display_name
    full_name.present? ? full_name : name
  end

  def to_param
    name
  end
end
