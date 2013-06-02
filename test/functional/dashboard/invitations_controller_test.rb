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
    assert_redirected_to dashboard_root_url(@workspace)


    logout
    get :show, :space_id => @workspace, :id => @invitation.token
    assert_response :success, @response.body

    login_as create(:user)
    get :show, :space_id => @workspace, :id => @invitation.token
    assert_response :success, @response.body
  end

  test "should create invitation" do
    assert_difference "@workspace.invitations.count" do
      post :create, :emails => [attributes_for(:invitation)[:email]], :space_id => @workspace, :format => :js
    end

    emails = 3.times.map { attributes_for(:invitation)[:email] }
    assert_difference "@workspace.invitations.count", 3 do
      post :create, :emails => emails, :space_id => @workspace, :format => :js
    end
  end

  test "should destroy invitation" do
    assert_difference "@workspace.invitations.count", -1 do
      delete :destroy, :id => @invitation, :space_id => @workspace, :format => :js
    end
  end

  test "should resend invitation" do
    assert_difference "Sidekiq::Extensions::DelayedMailer.jobs.size" do
      put :resend, :id => @invitation, :space_id => @workspace, :format => :js
    end
  end

  test "should accept invitation" do
    login_as create(:user)
    assert_difference "@workspace.invitations.count", -1 do
      assert_difference "@workspace.reload.members.count" do
        put :accept, :id => @invitation.token, :space_id => @workspace, :format => :js
      end
    end
  end

  test "members should not accept invitation" do
    assert_no_difference ["@workspace.reload.invitations.count", "@workspace.reload.members.count"] do
      put :accept, :id => @invitation.token, :space_id => @workspace, :format => :js
    end
  end

  test "should signup and join by invitation" do
    assert_no_difference ["@workspace.reload.invitations.count", "User.count", "@workspace.reload.members.count"] do
      post :join, :id => @invitation.token, :space_id => @workspace, :user => attributes_for(:user), :format => :js
    end

    logout
    assert_difference "@workspace.reload.invitations.count", -1 do
      assert_difference ["User.count", "@workspace.reload.members.count"] do
        post :join, :id => @invitation.token, :space_id => @workspace, :user => attributes_for(:user), :format => :js
      end
    end
  end
end
