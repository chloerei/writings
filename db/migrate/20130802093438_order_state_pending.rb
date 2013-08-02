class OrderStatePending < Mongoid::Migration
  def self.up
    Order.where(:state => 'pendding', :trade_no => nil).update_all(:state => 'opening')
  end

  def self.down
  end
end
