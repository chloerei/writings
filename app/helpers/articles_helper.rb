module ArticlesHelper
  def articles_is_end?(articles)
    articles.options[:skip].to_i + articles.to_a.count >= articles.count
  end
end
