class SplitUserAndSpace < Mongoid::Migration
  def self.up
    # remove Workspace
    Space.all.rename :creator_id => :user_id
    Invitation.all.rename :workspace_id => :space_id

    # split user
    user_attributes = [:email, :password_digest, :password_reset_token, :password_reset_token_created_at, :locale, :created_at, :updated_at]
    Space.where(:_type => 'User').asc(:_id).each do |space|
      user = User.new(space.attributes.splice(user_attributes + [:_id] ))
      user.save(:validate => true)
    end
    Space.all.unset(user_attributes + [:_type])

    # Order
    Order.all.rename :user_id => :space_id
  end

  def self.down
  end
end
