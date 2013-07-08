module SpaceToken
  extend ActiveSupport::Concern

  included do
    field :token

    belongs_to :space
    before_create :set_token
    index({ :space_id => 1, :token => 1 }, { :unique => true })

    validates_uniqueness_of :token, :scope => :space_id
    validates_presence_of :space
  end

  def set_token
    key = "#{self.class.collection_name}_next_id"
    self.token ||= space.inc(key => 1)[key].to_s
  end

  def to_param
    token.to_s
  end
end
