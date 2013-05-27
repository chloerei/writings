json.urlname @article.urlname
json.title @article.title
json.status @article.status
json.token @article.token
json.save_count @article.save_count
json.updated_at @article.updated_at

if action_name == 'edit'
  json.body @article.body
end

json.url site_article_url(@article)
json.host @space.host

if @article.locked?
  json.locked_user do
    locked_user = User.where(:id => @article.locked_by).first
    json.display_name locked_user.try(:display_name)
    json.name locked_user.try(:name)
  end
end

json.notes @article.notes.opening.group_by(&:element_id).map {|element_id, notes| [element_id, notes.count] } do |data|
  json.element_id data[0]
  json.count data[1]
end
