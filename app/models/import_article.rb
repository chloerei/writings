class ImportArticle
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title
  field :body
  field :urlname
  field :category
  field :published
  field :published_at, :type => Time

  belongs_to :import_task

  def import
    checked_urlname = import_task.space.articles(:urlname => urlname).exists? ? nil : urlname
    space_category = if category.present?
                       import_task.space.categories.find_or_create_by(:name => category)
                     end

    import_task.space.articles.create(
      :title        => title,
      :body         => body,
      :urlname      => checked_urlname,
      :category     => space_category,
      :status       => published? ? 'publish' : 'draft',
      :created_at   => created_at,
      :published_at => published_at
    )
  end
end
