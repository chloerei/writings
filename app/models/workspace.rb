class Workspace < Space
  belongs_to :owner, :class_name => 'User'
  has_and_belongs_to_many :members, :inverse_of => nil, :class_name => 'User'
end
