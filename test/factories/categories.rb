FactoryGirl.define do
  factory :category do
    sequence(:name){|n| "category#{n}" }
    sequence(:urlname){|n| "category#{n}" }

    user
  end
end
