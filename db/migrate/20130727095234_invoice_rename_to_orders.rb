class InvoiceRenameToOrders < Mongoid::Migration
  def self.up
    Mongoid.default_session.with(:db => 'admin').command :renameCollection => 'publish_production.invoices', :to => 'publish_production.orders'
    Order.update_all(:state => 'accepted')
    Order.all.rename(:approved_at => :accepted_at)
  end

  def self.down
  end
end
