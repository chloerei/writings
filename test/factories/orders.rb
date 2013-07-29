FactoryGirl.define do
  factory :order do
    user
    plan :base
    quantity 1
    price 20
  end
end
