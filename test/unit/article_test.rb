require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test "should generate token" do
    assert_not_nil create(:article).token
  end
end
