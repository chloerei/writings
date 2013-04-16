class Version
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :title
  field :body

  belongs_to :article
  belongs_to :user
end
