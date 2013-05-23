class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body

  belongs_to :discussion, :touch => true
  belongs_to :user

  validates_presence_of :body
end
