class Invitation
  include Mongoid::Document
  include Mongoid::Timestamps
  include Gravtastic

  gravtastic :filetype => :png, :size => 100

  field :token
  field :email
  field :message

  belongs_to :workspace

  before_create :set_token

  validates :email, :presence => true, :uniqueness => {:case_sensitive => false, :scope => :workspace_id }, :format => {:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/}

  def set_token
    self.token = SecureRandom.hex(16)
  end

  def send_mail
    InvitationMailer.delay.invite(id.to_s)
  end
end
