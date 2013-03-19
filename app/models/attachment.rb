class Attachment
  include Mongoid::Document

  field :file
  field :file_size

  belongs_to :user

  mount_uploader :file, FileUploader

  before_save :set_file_size

  def set_file_size
    if file.present? && file_changed?
      self.file_size = file.file.size
    end
  end
end
