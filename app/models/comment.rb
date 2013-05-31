class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body
  field :token

  belongs_to :discussion, :touch => true, :inverse_of => 'comments'
  belongs_to :user
  belongs_to :workspace

  validates_presence_of :body

  before_validation :set_token

  def set_token
    if new_record?
      self.token ||= workspace.inc(:comment_next_id, 1).to_s
    end
  end

  after_create :update_last_comment
  after_destroy :update_last_comment

  def update_last_comment
    discussion.update_last_comment
  end

  def to_param
    self.token.to_s
  end
end
