class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  field :plan, :type => Symbol
  field :quantity, :type => Integer
  field :price, :type => Integer, :default => 0
  field :discount, :type => Integer, :default => 0

  STATE = %w(opening pending paid completed canceled)
  field :state, :default => 'opening'
  field :pending_at, :type => Time
  field :completed_at, :type => Time
  field :canceled_at, :type => Time
  field :paid_at, :type => Time
  field :start_at, :type => Time
  field :trade_no

  belongs_to :space
  has_many :alipay_notifies

  scope :showable, where(:state.ne => 'opening')

  index({ :space_id => 1 })

  validates_presence_of :plan, :quantity, :price
  validates_inclusion_of :state, :in => STATE

  def total_price
    price * quantity + discount
  end

  def end_at
    start_at + quantity.months
  end

  STATE.each do |state|
    define_method "#{state}?" do
      self.state == state
    end
  end

  def pend
    if opening?
      update_attributes(
        :pending_at => Time.now.utc,
        :state       => 'pending'
      )
    end
  end

  def complete
    if pending? or paid?
      add_plan if pending?

      update_attributes(
        :completed_at => Time.now.utc,
        :state       => 'completed'
      )
    end
  end

  def cancel
    if pending? or paid?
      remove_plan if paid?
      update_attributes(
        :state       => 'canceled',
        :canceled_at => Time.now.utc
      )
    end
  end

  def pay
    if pending?
      update_attributes(
        :state   => 'paid',
        :paid_at => Time.now.utc
      )
      add_plan
    end
  end

  def add_plan
    start_at = (space.plan_expired_at && space.plan_expired_at > Time.now.utc) ? space.plan_expired_at : Time.now.utc

    update_attributes(
      :start_at    => start_at
    )

    space.update_attributes(
      :plan => plan,
      :plan_expired_at => start_at + quantity.months
    )
  end

  def remove_plan
    space.update_attributes(
      :plan_expired_at => space.plan_expired_at - quantity.months
    )
    space.orders.where(:start_at.gt => start_at).each do |order|
      order.update_attribute :start_at, order.start_at - quantity.months
    end
  end

  def pay_url
    Alipay::Service.create_partner_trade_by_buyer_url(
      :out_trade_no      => id.to_s,
      :price             => price,
      :quantity          => quantity,
      :discount          => discount,
      :subject           => "#{APP_CONFIG['site_name']} #{I18n.t "plan.#{plan}"} x #{quantity}",
      :logistics_type    => 'DIRECT',
      :logistics_fee     => '0',
      :logistics_payment => 'SELLER_PAY',
      :return_url        => Rails.application.routes.url_helpers.dashboard_order_url(:space_id => space, :id => self, :protocol => (APP_CONFIG['ssl'] ? 'https' : 'http'), :host => APP_CONFIG['host']),
      :notify_url        => Rails.application.routes.url_helpers.alipay_notify_dashboard_orders_url(:space_id => space, :protocol => (APP_CONFIG['ssl'] ? 'https' : 'http'), :host => APP_CONFIG['host']),
      :receive_name      => 'none',
      :receive_address   => 'none',
      :receive_zip       => '100000',
      :receive_mobile    => '100000000000'
    )
  end

  def send_good
    Alipay::Service.send_goods_confirm_by_platform(:trade_no => trade_no, :logistics_name => APP_CONFIG['site_name'], :transport_type => 'DIRECT')
  end
end
