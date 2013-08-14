class ImportArticle
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title
  field :body
  field :urlname
  field :category
  field :status
  field :published_at, :type => Time

  belongs_to :import_task

  def import
    space_category = if category.present?
                       import_task.space.categories.find_or_create_by(:name => category)
                     end

    import_task.space.articles.create(
      :title        => title,
      :body         => body,
      :urlname      => urlname.parameterize,
      :category     => space_category,
      :status       => status,
      :created_at   => created_at,
      :published_at => published_at,
      :user         => import_task.user
    )
  end
end
