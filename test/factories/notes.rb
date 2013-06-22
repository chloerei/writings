# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :note, :parent => :discussion, :class => 'Note' do
    article
    body 'text'
    element_id 'aaaa'
  end
end
