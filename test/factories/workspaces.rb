FactoryGirl.define do
  factory :workspace, :parent => :space, :class => 'Workspace' do
    owner
  end
end
