FactoryGirl.define do
  factory :order do
    space
    plan :base
    quantity 1
    price 20
  end
end
