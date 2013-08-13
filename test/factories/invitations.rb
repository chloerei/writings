# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invitation do
    sequence(:email){|n| "invitation_email#{n}@writings.io" }
    space
  end
end
