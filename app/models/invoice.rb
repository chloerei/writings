class Invoice
  include Mongoid::Document
  include Mongoid::Timestamps

  field :approved_at, :type => DateTime
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
    price + balance
  end

  def approved?
    !approved_at.blank?
  end

  def approve
    if !approved?
      self.start_at = user.plan_expired_at || Time.now.utc
      self.end_at = self.start_at + quantity.months
      self.approved_at = Time.now.utc
      save
      user.update_attribute :plan, plan
      user.update_attribute :plan_expired_at, end_at
    end
  end
end
