FactoryGirl.define do
  factory :workspace, :parent => :space, :class => 'Workspace' do
    creator :factory => :user
  end
end
