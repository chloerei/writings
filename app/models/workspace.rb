class Workspace < Space
  field :full_name

  belongs_to :owner, :class_name => 'User'
  has_and_belongs_to_many :members, :inverse_of => nil, :class_name => 'User'

  def display_name
    full_name.present? ? full_name : name
  end
end
