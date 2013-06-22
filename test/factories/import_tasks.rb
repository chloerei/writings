FactoryGirl.define do
  factory :import_task do
    space
    user
    file File.open("#{Rails.root}/test/files/wordpress.xml")
    format 'wordpress'
  end
end
