# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :attachment do
    user
    space
    file File.open('app/assets/images/rails.png')
  end
end
