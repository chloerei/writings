require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase
  test "should create attachment" do
    attachment = Attachment.create :file => File.open("#{Rails.root}/app/assets/images/rails.png")
    assert attachment.persisted?
    assert_not_nil attachment.file
  end
end
