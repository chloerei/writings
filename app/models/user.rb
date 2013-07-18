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

  has_many :creator_workspaces, :class_name => 'Workspace', :inverse_of => :creator

  has_secure_password

  validates :email, :presence => true, :uniqueness => {:case_sensitive => false}, :format => {:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/}
  validates :password, :length => { :minimum => 6 }, :on => :create
  validates :locale, :inclusion => {:in => ALLOW_LOCALE}
  validates :current_password, :presence => true, :if => :need_current_password

  attr_accessor :current_password, :need_current_password

  scope :in_plan, -> plan {
    if plan.to_s == 'free'
      scoped.or({:plan => plan}, {:plan_expired_at.lt => Time.now})
    else
      where(:plan => plan, :plan_expired_at.gt => Time.now)
    end
  }

  def workspaces
    Workspace.where(:member_ids => self.id)
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
        10.megabytes
      end
    else
      10.megabytes
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

  def workspace_limit
    return 999 if admin?

    if plan_expired_at.present? && plan_expired_at > Time.now
      case plan
      when :base
        1
      else
        1
      end
    else
      1
    end
  end

  def remain_workspace_count
    if creator_workspaces.count < workspace_limit
      workspace_limit - creator_workspaces.count
    else
      0
    end
  end
end
