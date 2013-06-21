class Discussion
  include Mongoid::Document
  include Mongoid::Timestamps
  include SpaceToken

  field :archived, :type => Boolean, :default => false

  belongs_to :user
  belongs_to :last_comment, :class_name => 'Comment'
  has_many :comments, :dependent => :delete

  scope :opening, where(:archived => false)
  scope :archived, where(:archived => true)

  def update_last_comment
    self.last_comment = comments.desc(:created_at).first
    save
  end
end
