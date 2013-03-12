require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test "should generate token" do
    assert_not_nil create(:article).token
  end

  test "should set published_at" do
    assert_nil create(:article).published_at
    assert_not_nil create(:article, :status => 'publish').published_at
    assert_not_nil create(:article).tap{ |a| a.update_attributes(:status => 'publish') }.published_at

    old_time = 1.hour.ago
    article = create(:article, :status => 'publish')
    article.update_attributes :published_at => old_time
    article.update_attributes :body => 'change'
    assert old_time.to_i == article.published_at.to_i
  end
end
