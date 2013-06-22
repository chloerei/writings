class CategoryUrlnameToToken < Mongoid::Migration
  def self.up
    Category.remove_indexes
    #Category.scoped.unset(:urlname, :description)
    Category.asc(:_id).each do |category|
      category.set_token
      category.save
    end
    Category.create_indexes
  end

  def self.down
  end
end
