class User < Space
  include ActiveModel::SecurePassword
  include Gravtastic

  gravtastic :filetype => :png, :size => 100

  field :email
  field :password_digest
  field :access_token
  field :locale, :default => I18n.locale.to_s
  field :plan, :type => Symbol, :default => :free
  field :plan_expired_at, :type => DateTime
  field :storage_used, :default => 0

  PLANS = %w(free base)

  embeds_one :profile
  has_many :own_workspaces, :class_name => 'Workspace', :inverse_of => :owner

  has_secure_password

  validates :email, :presence => true, :uniqueness => {:case_sensitive => false}, :format => {:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/}
  validates :password, :password_confirmation, :presence => true, :on => :create
  validates :password, :length => {:minimum => 6, :allow_blank => true}
  validates :locale, :inclusion => {:in => ALLOW_LOCALE}
  validates :current_password, :presence => true, :if => :need_current_password?
  validate :check_current_password, :if => :need_current_password?

  attr_accessor :current_password, :need_current_password

  before_create :build_profile

  def need_current_password?
    !!@need_current_password
  end

  def check_current_password
    unless authenticate(current_password)
      errors.add(:current_password, "is not match")
    end
  end

  def remember_token
    [id, Digest::SHA512.hexdigest(password_digest)].join('$')
  end

  def self.find_by_remember_token(token)
    user = where(:_id => token.split('$').first).first
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

  def display_name
    profile.name.present? ? profile.name : name
  end

  def in_plan?(plan)
    if plan == :free
      self.plan == plan || (plan_expired_at.present? &&plan_expired_at < Time.now)
    else
      self.plan == plan && (plan_expired_at.present? && plan_expired_at > Time.now)
    end
  end

  def storage_limit
    if plan_expired_at.present? && plan_expired_at > Time.now
      case plan
      when :base
        3.gigabytes
      else
        100.megabytes
      end
    else
      100.megabytes
    end
  end

  def version_limit
    if plan_expired_at.present? && plan_expired_at > Time.now
      case plan
      when :base
        100
      else
        5
      end
    else
      5
    end
  end
end
