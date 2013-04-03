xml.instruct!
xml.rss :version => "2.0" do
  xml.channel do
    xml.title @feed_title
    xml.link @feed_link
    xml.description
    xml.lastBuildDate @articles.first.published_at.to_s(:rfc822) if @articles.any?

    @articles.each do |article|
      xml.item do
        xml.title article.title
        xml.description do
          xml.cdata! article_format_body(convert_attachment_url(article_remove_h1(article.body), @user))
        end
        xml.pubDate article.published_at.to_s(:rfc822)
        xml.author @user.profile.name.present? ? @user.profile.name : @user.name
        xml.link site_article_url(article, :urlname => article.urlname)
        xml.guid site_article_url(article)
        if article.category.present?
          xml.category article.category.name
        end
      end
    end
  end
end
