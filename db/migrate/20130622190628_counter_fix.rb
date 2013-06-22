class CounterFix < Mongoid::Migration
  def self.up
    bad_time = Time.parse('2013-06-22 19:58:45 +800')

    Space.where(:articles_next_id => nil, :article_next_id.ne => nil).rename :article_next_id, :articles_next_id

    Space.where(:articles_next_id.ne => nil, :article_next_id.ne => nil).each do |space|
      space.update_attribute :articles_next_id, space.articles_next_id + space.article_next_id
      space.unset :article_next_id
    end

    Workspace.all.rename :discussion_next_id, :discussions_next_id
    Workspace.all.rename :comment_next_id, :comments_next_id
  end

  def self.down
  end
end
