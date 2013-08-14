require 'test_helper'

class Dashboard::AttachmentsControllerTest < ActionController::TestCase
  def setup
    @space = create(:space)
    login_as @space.user
  end

  test "should get index" do
    get :index, :space_id => @space
  end

  test "should create attachments" do
    assert_difference "@space.attachments.count" do
      post :create, :space_id => @space, :format => :json, :attachment => { :file => upload_file('app/assets/images/rails.png') }
      assert_response :success, @response.body
    end
  end
end
