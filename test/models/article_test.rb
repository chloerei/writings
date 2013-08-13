require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test "should generate token" do
    article = create :article
    assert_not_nil article.token
    assert_nil article.urlname
    assert_equal 1, article.token.to_i

    assert_equal 2, create(:article, :space => article.space).token.to_i
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

  test "should create version" do
    article = create :article
    user = create :user
    assert_difference "article.versions.count" do
      article.create_version :user => user
    end

    other_user = create :user
    assert_difference "article.versions.count" do
      article.create_version :user => other_user
    end
    assert_equal other_user, article.versions.asc(:created_at).last.user
  end

  test "should lock article" do
    user = create :user
    article = create :article, :space_id => user
    article.lock_by user
    assert article.locked?
    assert article.locked_by?(user)
  end
end
