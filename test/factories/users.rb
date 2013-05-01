FactoryGirl.define do
  factory :user, :parent => :space, :class => 'User' do
    sequence(:email){|n| "email#{n}@codecampo.com" }
    password 'password'
    password_confirmation 'password'
  end
end
