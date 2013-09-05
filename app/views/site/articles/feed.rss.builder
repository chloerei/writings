xml.instruct!
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @feed_title
    xml.link @feed_link
    xml.description
    xml.lastBuildDate @articles.first.published_at.to_s(:rfc822) if @articles.any?

    @articles.each do |article|
      cache [@space.name, article] do
        xml.item do
          xml.title article.title
          xml.description do
            xml.cdata! article_format_body(article_remove_h1(article.body))
          end
          xml.pubDate article.published_at.to_s(:rfc822)
          xml.author @space.display_name
          xml.link site_article_url(article, :urlname => article.urlname)
          xml.guid site_article_url(article)
        end
      end
    end
  end
end
