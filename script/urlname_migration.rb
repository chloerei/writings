Article.asc(:_id).each do |article|
  urlname_was = article.urlname
  if article.urlname.present?
    article.update_attribute :urlname, "#{article.token}-#{article.urlname}"
  else
    article.update_attribute :urlname, article.token
  end
  puts "#{urlname_was} -> #{article.urlname}"
end
