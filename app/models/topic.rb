class Topic < Discussion
  field :title
  field :body

  validates_presence_of :title, :body
end
