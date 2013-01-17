require 'test_helper'

class Site::BooksControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    @article = create :article, :user => @user
    @request.host = "#{@user.name}.local.test"
  end

  test "should get index" do

  end
end
