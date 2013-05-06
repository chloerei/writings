require 'test_helper'

class Dashboard::InvitationsControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @workspace = create :workspace, :owner => @user
    login_as @user
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
    invitation = create :invitation, :workspace => @workspace

    assert_difference "@workspace.invitations.count", -1 do
      delete :destroy, :id => invitation, :space_id => @workspace
    end
  end
end
