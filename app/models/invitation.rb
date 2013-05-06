class Invitation
  include Mongoid::Document

  field :token
  field :email

  belongs_to :workspace

  before_create :set_token

  def set_token
    self.token = SecureRandom.hex(16)
  end
end
