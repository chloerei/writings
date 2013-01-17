xml.instruct!
xml.rss :version => "2.0" do
  xml.channel do
    xml.title
    xml.link url_for(:only_path => false)
    xml.description
    xml.lastBuildDate @articles.first.created_at.to_s(:rfc822) if @articles.any?

    @articles.each do |article|
      xml.item do
        xml.title article.title
        xml.description do
          xml.cdata! article_format_body(article.body)
        end
        xml.pubDate article.created_at.to_s(:rfc822)
        xml.author @user.profile.name.present? ? @user.profile.name : @user.name
        xml.link site_article_url(article, :urlname => article.urlname)
        xml.guid site_article_url(article)
        if article.book.present?
          xml.category article.book.name
        end
      end
    end
  end
end
