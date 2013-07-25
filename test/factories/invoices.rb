# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invoice do
    user
    plan :base
    quantity 1
    price 20
  end
end
