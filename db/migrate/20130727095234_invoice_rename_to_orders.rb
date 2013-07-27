class InvoiceRenameToOrders < Mongoid::Migration
  def self.up
    Mongoid.default_session.with(:database => 'admin').command :renameCollection => 'publish_production.invoices', :to => 'publish_production.orders'
    Order.update_all(:state => 'completed')
    Order.all.rename(:approved_at => :completed_at)
  end

  def self.down
  end
end
