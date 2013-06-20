FactoryGirl.define do
  factory :import_article do
    title 'title'
    body 'body'
    sequence(:urlname) {|n| "#{n}import-article-url" }
    category 'category'
    published true
    published_at Time.now
    import_task
  end
end
