class AlipayNotify
  include Mongoid::Document

  field :verify, :type => Boolean
  field :params, :type => Hash

  belongs_to :order
end
