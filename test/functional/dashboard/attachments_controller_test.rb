require 'test_helper'

class Dashboard::AttachmentsControllerTest < ActionController::TestCase
  def setup
    @user = create(:user)
    login_as @user
  end

  test "should get index" do
    get :index
  end

  test "should create attachments" do
    assert_difference "current_user.attachments.count" do
      post :create, :format => :json, :attachment => { :file => File.open('app/assets/images/rails.png') }
      assert_response :success, @response.body
    end
  end

  test "should show current_user attachment" do
    attachment = create :attachment, :user => @user
    get :show, :id => attachment.id
    assert_response 302

    login_as create(:user)
    assert_raise(Mongoid::Errors::DocumentNotFound) do
      get :show, :id => attachment.id
    end
  end
end
