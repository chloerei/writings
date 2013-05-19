class Topic < Discussion
  field :title
  field :body

  belongs_to :user
end
