class InvoiceRenameToOrders < Mongoid::Migration
  def self.up
    Mongoid.default_session.with(:database => 'admin').command :renameCollection => 'publish_production.invoices', :to => 'publish_production.orders'
    Order.update_all(:state => 'completed')
    Order.all.rename(:approved_at => :completed_at)
    Order.all.unset(:end_at)
    Order.all.each do |order|
      order.user.update_attribute :plan_expired_at, order.user.plan_expired_at + order.quantity.months
      order.price = 10
      order.quantity = order.quantity  * 2
      order.save
    end
  end

  def self.down
  end
end
