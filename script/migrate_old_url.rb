Article.asc(:_id).each do |article|
  if article.urlname == article.token
    # {token}
    article.update_attribute :urlname, nil
  else
    article.old_url = article.urlname

    if article.urlname.split('-').first == article.token
      # {token-urlname}
      article.urlname = article.urlname.split('-')[1..-1].join('-')
    else
      # {urlname}
    end

    article.save
  end
end
