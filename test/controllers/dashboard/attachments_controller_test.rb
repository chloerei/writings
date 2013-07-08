require 'test_helper'

class Dashboard::AttachmentsControllerTest < ActionController::TestCase
  def setup
    @user = create(:user)
    login_as @user
  end

  test "should get index" do
    get :index, :space_id => @user
  end

  test "should create attachments" do
    assert_difference "current_user.attachments.count" do
      post :create, :space_id => @user, :format => :json, :attachment => { :file => upload_file('app/assets/images/rails.png') }
      assert_response :success, @response.body
    end
  end
end
