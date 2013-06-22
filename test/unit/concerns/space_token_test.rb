require 'test_helper'

class SpaceTokenTest < ActiveSupport::TestCase
  class Foo
    include Mongoid::Document
    include SpaceToken
  end

  def setup
    @space = create :user
  end

  test "should generate token" do
    assert_equal nil, @space["space_token_test_foos_next_id"]
    foo = Foo.new :space => @space
    foo.save
    assert_not_nil foo.token
    assert_equal 1, @space.reload["space_token_test_foos_next_id"]
  end
end
