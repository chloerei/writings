class Discussion
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status, :default => 'open'
  field :archived, :default => false

  belongs_to :workspace
  has_many :comments
end
