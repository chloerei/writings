FactoryGirl.define do
  factory :user do
    sequence(:name){|n| "name#{n}" }
    sequence(:email){|n| "email#{n}@codecampo.com" }
    password 'password'
    password_confirmation 'password'
  end
end
