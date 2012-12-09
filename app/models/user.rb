class User
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include ActiveModel::SecurePassword

  field :name
  field :email
  field :password_digest
  field :access_token
  field :locale, :default => I18n.locale.to_s

  has_secure_password

  class ConfirmationValidator < ActiveModel::EachValidator # :nodoc:
    def initialize(options)
      options[:attributes] = options[:attributes].map { |attribute| "#{attribute}_confirmation" }
      super
    end

    def validate_each(record, attribute, value)
      attribute_to_confirm = attribute.to_s.sub('_confirmation', '')
      confirmed = record.send(attribute_to_confirm)
      if value != confirmed
        human_attribute_name = record.class.human_attribute_name(attribute_to_confirm)
        record.errors.add(attribute, :confirmation, options.merge(:attribute => human_attribute_name))
      end
    end

    def client_side_hash(model, attribute, force = nil)
      attribute_to_confirm = attribute.to_s.split(/_confirmation/)[0]
      human_attribute_name = model.class.human_attribute_name(attribute_to_confirm)
      build_client_side_hash(model, attribute, self.options.dup.merge(:attribute => human_attribute_name))
    end

    def setup(klass)
      klass.send(:attr_accessor, *attributes.map do |attribute|
        attribute unless klass.method_defined?(attribute)
      end.compact)
    end
  end

  validates :password, :confirmation => true

  validates :name, :email, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :name, :format => {:with => /\A\w+\z/, :message => 'only A-Z, a-z, _ allowed'}, :length => {:in => 3..20}
  validates :email, :format => {:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/}
  validates :password, :password_confirmation, :presence => true, :on => :create
  validates :password, :length => {:minimum => 6, :allow_nil => true}
  validates :locale, :inclusion => {:in => ALLOW_LOCALE}

  attr_accessor :current_password
  attr_accessible :name, :email, :password, :password_confirmation, :current_password, :locale

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
end
