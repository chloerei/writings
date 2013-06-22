class Workspace < Space
  include Gravtastic

  gravtastic :gravatar_email, :filetype => :png, :size => 100

  field :full_name
  field :gravatar_email

  belongs_to :creator, :class_name => 'User'
  has_and_belongs_to_many :members, :inverse_of => nil, :class_name => 'User'
  has_many :invitations, :dependent => :delete

  index({ :creator_id => 1 })
  index({ :member_ids => 1 })

  delegate :storage_limit, :storage_used, :in_plan?, :version_limit, :to => :creator

  def display_name
    full_name.present? ? full_name : name
  end

  before_create :add_creator_to_members

  def add_creator_to_members
    self.members << creator
  end
end
