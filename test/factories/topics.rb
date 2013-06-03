FactoryGirl.define do
  factory :topic, :parent => :discussion, :class => 'Topic' do
    title 'title'
    body 'body'
  end
end
