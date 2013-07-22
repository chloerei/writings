json.urlname @article.urlname
json.title @article.title
json.status @article.status
json.token @article.token
json.save_count @article.save_count
json.updated_at @article.updated_at
json.body @article.body
json.url site_article_url(@article, :host => @space.host, :protocol => 'http')
json.host @space.host

if @article.locked?
  json.locked_user do
    locked_user = User.where(:id => @article.locked_by).first
    json.display_name locked_user.try(:display_name)
    json.name locked_user.try(:name)
  end
end
