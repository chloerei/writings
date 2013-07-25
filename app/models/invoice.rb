class Invoice
  include Mongoid::Document
  include Mongoid::Timestamps

  field :plan, :type => Symbol
  field :quantity, :type => Integer
  field :price, :type => Integer, :default => 0
  field :discount, :type => Integer, :default => 0

  STATE = %w(pendding payed accepted canceled)
  field :state, :default => 'pendding'
  field :accepted_at, :type => DateTime
  field :canceled_at, :type => DateTime
  field :start_at, :type => DateTime
  field :end_at, :type => DateTime

  field :remark

  belongs_to :user

  index({ :user_id => 1 })

  validates_presence_of :plan, :quantity, :price
  validates_inclusion_of :state, :in => STATE

  def total_price
    price * quantity + discount
  end

  STATE.each do |state|
    define_method "#{state}?" do
      self.state == state
    end
  end

  def accept
    if state == 'pendding'
      start_at = user.plan_expired_at || Time.now.utc
      update_attributes(
        :start_at    => start_at,
        :end_at      => start_at + quantity.months,
        :accepted_at => Time.now.utc,
        :state       => 'accepted'
      )

      user.update_attributes(
        :plan => plan,
        :plan_expired_at => end_at
      )
    end
  end

  def cancel
    if state == 'pendding'
      update_attributes(
        :state       => 'canceled',
        :canceled_at => Time.now.utc
      )
    end
  end

  def pay_url
    Alipay::Payments::DualFun.new(
      :out_trade_no      => id.to_s,
      :price             => price,
      :quantity          => quantity,
      :discount          => discount,
      :subject           => "#{APP_CONFIG['host']} #{plan}",
      :logistics_type    => 'POST',
      :logistics_fee     => '0',
      :logistics_payment => 'SELLER_PAY'
    ).generate_pay_url
  end
end
