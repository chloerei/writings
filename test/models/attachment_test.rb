require 'test_helper'

class AttachmentTest < ActiveSupport::TestCase
  test "should create attachment" do
    attachment = create :attachment, :file => File.open("#{Rails.root}/app/assets/images/rails.png")
    assert attachment.persisted?
    assert_not_nil attachment.file
    assert_not_nil attachment.file_size
  end

  test "should change space storage_used" do
    file = File.open("#{Rails.root}/app/assets/images/rails.png")
    space = create :space
    assert_difference "space.storage_used", file.size do
      space.attachments.create :file => file, :user => create(:user)
    end
    assert_difference "space.storage_used", -file.size do
      space.attachments.last.destroy
    end
  end

  test "should valid false if touch space sotre limit" do
    space = create :space
    assert build(:attachment, :space => space).valid?
    space.update_attribute :storage_used, space.storage_limit
    assert !build(:attachment, :space => space).valid?
  end
end
