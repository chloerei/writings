class Workspace < Space
  field :full_name

  belongs_to :creator, :class_name => 'User'
  has_and_belongs_to_many :members, :inverse_of => nil, :class_name => 'User'
  has_many :invitations

  delegate :storage_limit, :storage_used, :in_plan?, :version_limit, :to => :creator

  def display_name
    full_name.present? ? full_name : name
  end
end
