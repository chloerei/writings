class Attachment
  include Mongoid::Document

  field :file
  field :file_size

  belongs_to :user

  mount_uploader :file, FileUploader

  before_create :set_file_size
  after_create :inc_user_store_used
  after_destroy :dec_user_store_used

  validate :check_user_store_limit, :on => :create

  def set_file_size
    if file.present? && file_changed?
      self.file_size = file.file.size
    end
  end

  def inc_user_store_used
    user.inc(:store_used, file_size)
  end

  def dec_user_store_used
    user.inc(:store_used, -file_size)
  end

  def check_user_store_limit
    if user.store_used + file.file.size > user.store_limit
      errors.add(:file, I18n.t('errors.messages.store_limit'))
    end
  end
end
