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
    # TODO category

    import_task.space.articles.create(
      :title        => title,
      :body         => body,
      :urlname      => checked_urlname,
      :status       => published? ? 'publish' : 'draft',
      :created_at   => created_at,
      :published_at => published_at
    )
  end
end
