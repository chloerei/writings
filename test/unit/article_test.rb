require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test "should generate number_id by user" do
    user_one = create :user
    assert_equal 1, create(:article, :user => user_one).number_id
    assert_equal 2, create(:article, :user => user_one).number_id

    user_two = create :user
    assert_equal 1, create(:article, :user => user_two).number_id
  end
end
