FactoryGirl.define do
  factory :workspace, :parent => :space, :class => 'Workspace' do
    owner :factory => :user
  end
end
