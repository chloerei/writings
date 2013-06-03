class Discussion
  include Mongoid::Document
  include Mongoid::Timestamps

  field :archived, :type => Boolean, :default => false
  field :token

  belongs_to :workspace
  belongs_to :user
  belongs_to :last_comment, :class_name => 'Comment'
  has_many :comments, :dependent => :delete

  index({ :workspace_id => 1, :token => 1 }, { :unique => true })

  scope :opening, where(:archived => false)
  scope :archived, where(:archived => true)

  before_validation :set_token

  def set_token
    if new_record?
      self.token ||= workspace.inc(:discussion_next_id, 1).to_s
    end
  end

  def to_param
    self.token.to_s
  end

  def update_last_comment
    self.last_comment = comments.desc(:created_at).first
    save
  end
end
