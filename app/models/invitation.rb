class Invitation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Gravtastic

  gravtastic :filetype => :png, :size => 100

  field :token
  field :email
  field :message

  belongs_to :space

  index({ :space_id => 1, :token => 1 }, { :unique => true })

  validates :email, :presence => true, :uniqueness => {:case_sensitive => false, :scope => :space_id }, :format => {:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/}

  before_create :set_token

  def set_token
    self.token = SecureRandom.hex(16)
  end

  after_create :send_mail

  def send_mail
    InvitationMailer.delay.invite(id.to_s)
  end
end
