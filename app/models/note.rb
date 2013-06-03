class Note < Discussion
  field :body
  field :element_id

  belongs_to :article

  index({ :article_id  => 1 })
  validates_presence_of :body, :element_id
end
