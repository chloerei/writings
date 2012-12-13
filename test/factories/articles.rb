# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :article do
    sequence(:urlname){|n| "urlname#{n}" }
    book
    user
  end
end
