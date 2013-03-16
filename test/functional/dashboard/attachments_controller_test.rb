require 'test_helper'

class Dashboard::AttachmentsControllerTest < ActionController::TestCase
  def setup
    @user = create(:user)
    login_as @user
  end

  test "should create attachements" do
    assert_difference "Attachment.count" do
      post :create, :format => :json, :attachment => { :file => File.open('app/assets/images/rails.png') }
      assert_response :success, @response.body
    end
  end
end
