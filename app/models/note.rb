class Note < Discussion
  field :body
  field :element_id

  belongs_to :article

  validates_presence_of :body, :element_id
end
