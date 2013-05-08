require 'test_helper'

class Dashboard::InvitationsControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @workspace = create :workspace, :creator => @user
    @invitation = create :invitation, :workspace => @workspace
    login_as @user
  end

  test "should show invitation by token" do
    get :show, :space_id => @workspace, :id => @invitation.token
    assert_response :success, @response.body
  end

  test "should create invitation" do
    assert_difference "@workspace.invitations.count" do
      post :create, :emails => [attributes_for(:invitation)[:email]], :space_id => @workspace
    end

    emails = 3.times.map { attributes_for(:invitation)[:email] }
    assert_difference "@workspace.invitations.count", 3 do
      post :create, :emails => emails, :space_id => @workspace
    end
  end

  test "should destroy invitation" do
    assert_difference "@workspace.invitations.count", -1 do
      delete :destroy, :id => @invitation, :space_id => @workspace
    end
  end

  test "should resend invitation" do
    assert_difference "ActionMailer::Base.deliveries.count" do
      put :resend, :id => @invitation, :space_id => @workspace
    end
  end

  test "should accept invitation" do
    login_as create(:user)
    assert_difference "@workspace.invitations.count", -1 do
      assert_difference "@workspace.reload.members.count" do
        put :accept, :id => @invitation.token, :space_id => @workspace
      end
    end
  end
end
