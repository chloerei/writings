FactoryGirl.define do
  factory :user do
    sequence(:name){|n| "username#{n}" }
    sequence(:email){|n| "email#{n}@codecampo.com" }
    password 'password'
    password_confirmation 'password'
  end
end
