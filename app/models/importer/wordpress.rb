class Importer::Wordpress < Importer::Base
  def import
    Dir.chdir(tmp_path) do
      xml = Nokogiri::XML(file.read)

      xml.xpath('rss/channel/item').each do |item|
        begin
          title = item.xpath('title').text
          body = PandocRuby.convert(item.xpath('content:encoded').text, :from => :markdown, :to => :html)
          if title.present?
            body = "<h1>#{title}</h1>\n" + body
          end
          status = (item.xpath('wp:status').text == 'publish' ? 'publish' : 'draft')
          urlname = item.xpath('wp:post_name').text
          created_at = Time.parse(item.xpath('wp:post_date').text).utc# rescue nil
          publishded_at = Time.parse(item.xpath('pubDate').text).utc rescue nil

          article = ImportArticle.new(
            :title        => title,
            :body         => body,
            :status       => status,
            :urlname      => urlname,
            :created_at   => created_at,
            :published_at => publishded_at
          )

          yield article
        rescue => e
          # ignore on production
          raise e unless Rails.env.production?
        end
      end
    end
  end
end
