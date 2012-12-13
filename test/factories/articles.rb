# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :article do
    sequence(:urlname){|n| "urlname#{n}" }
    title 'title'
    body '<p>body</p>'

    book
    user
  end
end
