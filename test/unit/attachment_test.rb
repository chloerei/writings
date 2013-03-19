require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase
  test "should create attachment" do
    attachment = create :attachment, :file => File.open("#{Rails.root}/app/assets/images/rails.png")
    assert attachment.persisted?
    assert_not_nil attachment.file
    assert_not_nil attachment.file_size
  end

  test "should change user store_used" do
    file = File.open("#{Rails.root}/app/assets/images/rails.png")
    user = create :user
    assert_difference "user.store_used", file.size do
      user.attachments.create :file => file
    end
    assert_difference "user.store_used", -file.size do
      user.attachments.last.destroy
    end
  end
end
