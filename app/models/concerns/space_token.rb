module SpaceToken
  extend ActiveSupport::Concern

  included do
    field :token

    belongs_to :space
    before_create :set_token
    index({ :space_id => 1, :token => 1 }, { :unique => true })

    validates_presence_of :space
  end

  def set_token
    self.token ||= space.inc("#{self.class.name.underscore}_next_id", 1).to_s
  end

  def to_param
    token.to_s
  end
end
