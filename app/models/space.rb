class Space
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::ForbiddenAttributesProtection

  field :name
  field :domain
  field :disqus_shortname
  field :full_name
  field :description

  has_many :categories, :dependent => :delete
  has_many :articles, :dependent => :delete
  has_many :attachments, :dependent => :destroy
  has_many :export_tasks, :dependent => :destroy
  has_many :import_tasks, :dependent => :destroy

  index({ :name => 1 }, { :unique => true })
  index({ :domain => 1 }, { :unique => true, :sparse => true})

  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, :format => {:with => /\A[a-zA-Z0-9-]+\z/, :message => I18n.t('errors.messages.space_name') }, :length => {:in => 4..20}
  validates :domain, :format => {:with => /\A[a-zA-Z0-9_\-.]+\z/}, :uniqueness => {:case_sensitive => false}, :allow_blank => true

  validate :except_host

  def except_host
    if domain =~ /#{Regexp.escape APP_CONFIG["host"]}/
      errors.add(:domain, I18n.t('errors.messages.invalid'))
    end
  end

  def host
    domain.present? ? domain : "#{name}.#{APP_CONFIG['host']}"
  end

  def to_param
    name.to_s
  end

  def display_name
    full_name.present? ? full_name : name
  end

end
