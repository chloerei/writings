require 'test_helper'

class Dashboard::InvitationsControllerTest < ActionController::TestCase
  def setup
    @space = create :space, :plan => :base, :plan_expired_at => 1.day.from_now
    @invitation = create :invitation, :space => @space
    login_as @space.user
  end

  test "should show invitation by token" do
    get :show, :space_id => @space, :id => @invitation.token
    assert_redirected_to dashboard_root_url(@space)


    logout
    get :show, :space_id => @space, :id => @invitation.token
    assert_response :success, @response.body

    login_as create(:user)
    get :show, :space_id => @space, :id => @invitation.token
    assert_response :success, @response.body
  end

  test "should create invitation" do
    assert_difference "@space.invitations.count" do
      post :create, :emails => [attributes_for(:invitation)[:email]], :space_id => @space, :format => :js
    end

    emails = 3.times.map { attributes_for(:invitation)[:email] }
    assert_difference "@space.invitations.count", 3 do
      post :create, :emails => emails, :space_id => @space, :format => :js
    end
  end

  test "should not create invitation if in plan free" do
    @space.update_attribute :plan, :free
    assert_no_difference "@space.invitations.count" do
      post :create, :emails => [attributes_for(:invitation)[:email]], :space_id => @space, :format => :js
    end

    @space.update_attributes :plan => :base, :plan_expired_at => 1.day.ago
    assert_no_difference "@space.invitations.count" do
      post :create, :emails => [attributes_for(:invitation)[:email]], :space_id => @space, :format => :js
    end
  end

  test "should destroy invitation" do
    assert_difference "@space.invitations.count", -1 do
      delete :destroy, :id => @invitation, :space_id => @space, :format => :js
    end
  end

  test "should resend invitation" do
    assert_difference "Sidekiq::Extensions::DelayedMailer.jobs.size" do
      put :resend, :id => @invitation, :space_id => @space, :format => :js
    end
  end

  test "should accept invitation" do
    login_as create(:user)
    assert_difference "@space.invitations.count", -1 do
      assert_difference "@space.reload.members.count" do
        put :accept, :id => @invitation.token, :space_id => @space, :format => :js
      end
    end
  end

  test "members should not accept invitation" do
    assert_no_difference ["@space.reload.invitations.count", "@space.reload.members.count"] do
      put :accept, :id => @invitation.token, :space_id => @space, :format => :js
    end
  end

  test "should signup and join by invitation" do
    assert_no_difference ["@space.reload.invitations.count", "User.count", "@space.reload.members.count"] do
      post :join, :id => @invitation.token, :space_id => @space, :user => attributes_for(:user), :format => :js
    end

    logout
    assert_difference "@space.reload.invitations.count", -1 do
      assert_difference ["User.count", "@space.reload.members.count"] do
        post :join, :id => @invitation.token, :space_id => @space, :user => attributes_for(:user), :format => :js
      end
    end
  end
end
