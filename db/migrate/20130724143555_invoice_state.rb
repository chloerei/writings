class InvoiceState < Mongoid::Migration
  def self.up
    Invoice.update_all(:state => :approved)
  end

  def self.down
  end
end
