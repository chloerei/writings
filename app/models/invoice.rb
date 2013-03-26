class Invoice
  include Mongoid::Document
  include Mongoid::Timestamps

  field :paid_at
  field :plan, :type => Symbol
  field :quantity, :type => Integer
  field :price, :type => Integer, :default => 0
  field :balance, :type => Integer, :default => 0

  field :start_at, :type => DateTime
  field :end_at, :type => DateTime

  field :remark

  belongs_to :user

  validates_presence_of :plan, :quantity, :price, :balance

  def total_price
    price - balance
  end
end
