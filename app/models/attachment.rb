class Attachment
  include Mongoid::Document

  field :file

  belongs_to :user

  mount_uploader :file, FileUploader
end
