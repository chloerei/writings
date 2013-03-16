class Attachment
  include Mongoid::Document

  field :file

  belongs_to :user
  belongs_to :article

  mount_uploader :file, FileUploader
end
