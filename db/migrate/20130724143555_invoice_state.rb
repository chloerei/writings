class InvoiceState < Mongoid::Migration
  def self.up
    Invoice.update_all(:state => 'accepted')
    Invoice.all.rename(:approved_at => :accepted_at)
  end

  def self.down
  end
end
