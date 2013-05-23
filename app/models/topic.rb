class Topic < Discussion
  field :title
  field :body

  belongs_to :user

  validates_presence_of :title, :body
end
