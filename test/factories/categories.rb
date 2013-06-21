FactoryGirl.define do
  factory :category do
    sequence(:name){|n| "category#{n}" }
    space
  end
end
