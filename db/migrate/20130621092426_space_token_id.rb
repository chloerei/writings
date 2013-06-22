class SpaceTokenId < Mongoid::Migration
  def self.up
    Comment.all.rename(:workspace_id, :space_id)
    Discussion.all.rename(:workspace_id, :space_id)
  end

  def self.down
  end
end
