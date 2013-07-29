class AlipayNotify
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :verify, :type => Boolean
  field :params, :type => Hash

  belongs_to :order
end
