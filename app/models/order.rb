class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  field :plan, :type => Symbol
  field :quantity, :type => Integer
  field :price, :type => Integer, :default => 0
  field :discount, :type => Integer, :default => 0

  STATE = %w(pendding paid completed canceled)
  field :state, :default => 'pendding'
  field :completed_at, :type => DateTime
  field :canceled_at, :type => DateTime
  field :paid_at, :type => DateTime
  field :start_at, :type => DateTime
  field :end_at, :type => DateTime
  field :trade_no

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

  def complete
    if pendding? or paid?
      add_plan if pendding?

      update_attributes(
        :completed_at => Time.now.utc,
        :state       => 'completed'
      )
    end
  end

  def cancel
    if pendding? or paid?
      remove_plan if paid?
      update_attributes(
        :state       => 'canceled',
        :canceled_at => Time.now.utc
      )
    end
  end

  def pay
    if pendding?
      update_attributes(
        :state   => 'paid',
        :paid_at => Time.now.utc
      )
      add_plan
    end
  end

  def add_plan
    start_at = (user.plan_expired_at && user.plan_expired_at > Time.now.utc) ? user.plan_expired_at : Time.now.utc
    end_at = start_at + quantity.months

    update_attributes(
      :start_at    => start_at,
      :end_at      => end_at
    )

    user.update_attributes(
      :plan => plan,
      :plan_expired_at => end_at
    )
  end

  def remove_plan
    user.update_attributes(
      :plan_expired_at => user.plan_expired_at - quantity.months
    )
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
      :logistics_payment => 'SELLER_PAY',
      :return_url        => Rails.application.routes.url_helpers.order_url(self),
      :notify_url        => Rails.application.routes.url_helpers.alipay_notify_orders_url,
      :receive_name      => 'none',
      :receive_address   => 'none',
      :receive_zip       => '100000',
      :receive_mobile    => '100000000000'
    ).generate_pay_url
  end

  def send_good
    Alipay::SendGoods.new(:trade_no => trade_no, :logistics_name => 'writings.io').send_good
  end
end
