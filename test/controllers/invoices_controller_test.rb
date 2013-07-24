require 'test_helper'

class InvoicesControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    login_as @user
  end

  test "should get new page" do
    get :new
    assert_response :success, @response.body
  end

  test "should create invoice and redirect to alipay" do
    assert_difference "@user.invoices.count" do
      post :create, :invoice => { :quantity => 1 }
      assert_equal 1, assigns(:invoice).quantity
    end
    assert_redirected_to assigns(:invoice).pay_url
  end

  test "should have discount" do
    assert_difference "@user.invoices.count" do
      post :create, :invoice => { :quantity => 1 }
      assert_equal 0, assigns(:invoice).discount
    end

    assert_difference "@user.invoices.count" do
      post :create, :invoice => { :quantity => 6 }
      assert_equal 20, assigns(:invoice).discount
    end

    assert_difference "@user.invoices.count" do
      post :create, :invoice => { :quantity => 12 }
      assert_equal 40, assigns(:invoice).discount
    end

    assert_no_difference "@user.invoices.count" do
      post :create, :invoice => { :quantity => 11 }
      assert_equal 0, assigns(:invoice).discount
    end
  end
end
