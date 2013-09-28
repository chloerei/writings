class Space
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::ForbiddenAttributesProtection
  include Gravtastic

  gravtastic :gravatar_email, :filetype => :png, :size => 100

  field :name
  field :domain
  field :disqus_shortname
  field :google_analytics_id
  field :full_name
  field :description
  field :gravatar_email
  field :plan, :type => Symbol, :default => :free
  field :plan_expired_at, :type => Time
  field :storage_used, :default => 0

  has_many :articles, :dependent => :delete
  has_many :attachments, :dependent => :destroy
  has_many :export_tasks, :dependent => :destroy
  has_many :import_tasks, :dependent => :destroy
  has_many :invitations, :dependent => :delete
  has_many :orders, :dependent => :delete
  belongs_to :user
  has_and_belongs_to_many :members, :inverse_of => nil, :class_name => 'User'

  index({ :user_id => 1 })
  index({ :name => 1 }, { :unique => true })
  index({ :domain => 1 }, { :unique => true, :sparse => true})
  index({ :member_ids => 1 })

  PLANS = %w(free base)

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, :format => {:with => /\A[a-z0-9-]+\z/, :message => I18n.t('errors.messages.space_name') }, :length => {:in => 4..20}
  validates :domain, :format => {:with => /\A[a-zA-Z0-9_\-.]+\z/}, :uniqueness => {:case_sensitive => false}, :allow_blank => true

  validate :except_host

  scope :in_plan, -> plan {
    if plan.to_s == 'free'
      scoped.or({:plan => plan}, {:plan_expired_at.lt => Time.now})
    else
      where(:plan => plan, :plan_expired_at.gt => Time.now)
    end
  }

  def except_host
    if domain =~ /#{Regexp.escape APP_CONFIG["host"]}/
      errors.add(:domain, I18n.t('errors.messages.invalid'))
    end
  end

  def host
    (domain_enabled? && domain.present?) ? domain : "#{name}.#{APP_CONFIG['host']}"
  end

  def to_param
    name.to_s
  end

  def display_name
    full_name.present? ? full_name : name
  end

  before_create :add_user_to_members

  def add_user_to_members
    self.members << user
  end

  def in_plan?(plan)
    if plan == :free
      self.plan == plan || plan_expired_at.blank? || plan_expired_at < Time.now
    else
      self.plan == plan && plan_expired_at.present? && plan_expired_at > Time.now
    end
  end

  def storage_limit
    if plan_expired_at.present? && plan_expired_at > Time.now
      case plan
      when :base
        1.gigabytes
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
        50
      else
        5
      end
    else
      5
    end
  end

  def domain_enabled?
    !in_plan?(:free)
  end
end
