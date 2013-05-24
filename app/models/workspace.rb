class Workspace < Space
  field :full_name

  belongs_to :creator, :class_name => 'User'
  has_and_belongs_to_many :members, :inverse_of => nil, :class_name => 'User'
  has_many :invitations, :dependent => :delete
  has_many :discussions, :dependent => :delete
  has_many :topics, :dependent => :delete
  has_many :comments, :dependent => :delete

  delegate :storage_limit, :storage_used, :in_plan?, :version_limit, :to => :creator

  def display_name
    full_name.present? ? full_name : name
  end

  before_create :add_creator_to_members

  def add_creator_to_members
    self.members << creator
  end
end
