class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body
  field :token

  belongs_to :discussion, :touch => true
  belongs_to :user
  belongs_to :workspace

  validates_presence_of :body

  before_validation :set_token

  def set_token
    if new_record?
      self.token ||= workspace.inc(:comment_next_id, 1).to_s
    end
  end

  def to_param
    self.token.to_s
  end
end
