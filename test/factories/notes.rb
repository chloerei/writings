# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :note do
    user
    workspace
    article
    body 'text'
    element_id 'aaaa'
  end
end
