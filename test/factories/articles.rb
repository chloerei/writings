# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :article do
    sequence(:urlname){|n| "urlname#{n}" }
    sequence(:title){|n| "title #{n}" }
    body '<p>body</p>'
  end
end
