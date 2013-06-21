class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include SpaceToken

  field :body

  belongs_to :discussion, :touch => true, :inverse_of => 'comments'
  belongs_to :user

  validates_presence_of :body

  after_create :update_last_comment
  after_destroy :update_last_comment

  def update_last_comment
    discussion.update_last_comment
  end
end
