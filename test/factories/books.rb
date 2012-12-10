FactoryGirl.define do
  factory :book do
    sequence(:name){|n| "book#{n}" }
    sequence(:urlname){|n| "book#{n}" }

    user
  end
end
