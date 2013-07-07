class RemoveDiscussionsTopicsComments < Mongoid::Migration
  def self.up
    session = Mongoid::Sessions.default
    session[:discussions].drop
    session[:comments].drop
    Space.all.unset(:discussions_next_id)
    Space.all.unset(:comments_next_id)
  end

  def self.down
  end
end
