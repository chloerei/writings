class Exporter::Wordpress < Exporter::Base
  RSS_ATTRIBUTES = {
    'version'       => '2.0',
    'xmlns:excerpt' => 'http://wordpress.org/export/1.2/excerpt/',
    'xmlns:content' => 'http://purl.org/rss/1.0/modules/content/',
    'xmlns:dc'      => 'http://purl.org/dc/elements/1.1/',
    'xmlns:wp'      => 'http://wordpress.org/export/1.2/'
  }

  def export
    prepare

    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|

      xml.rss(RSS_ATTRIBUTES) do
        xml.channel do
          xml.title @space.name
          xml.link @space.host
          xml.description @space.description
          xml.pubdate Time.now.utc.rfc2822

          xml['wp'].wxr_version '1.2'
          xml['wp'].base_site_url 'http://writings.io'
          xml['wp'].base_blog_url "http://#{@space.host}"

          xml.generator "http://writings.io"

          articles.each do |article|
            xml.item do
              xml.title article.title
              xml.link url_helper.site_article_url(:id => article, :urlname => article.urlname, :host => @space.host)
              xml.pubDate article.published_at.try(:rfc2822)
              xml['dc'].creator @space.name
              xml['content'].encoded do
                xml.cdata clean_body(article.body)
              end
              xml['wp'].post_date article.created_at
              xml['wp'].post_type 'post'
              xml['wp'].post_name (article.urlname.present? ? "#{article.token}-#{article.urlname}" : article.token)
              xml['wp'].status article.status
            end
          end
        end
      end
    end

    File.open("#{output_path}/wordpress.xml", 'w') do |f|
      f.write builder.to_xml
    end

    clean
  end
end
