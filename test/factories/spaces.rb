FactoryGirl.define do
  factory :space do
    sequence(:name){|n| "spacename#{n}" }
  end
end
