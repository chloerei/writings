module ArticlesHelper
  def articles_is_end?(articles)
    articles.options[:skip].to_i + articles.to_a.count >= articles.count
  end

  def article_format_body(text)
    sanitize text, :tags => %w(p br img h1 h2 h3 h4 blockquote pre code b i strike u a ul ol li), :attributes => %w(href src id)
  end

  def article_summary_body(text)
    doc = Nokogiri::HTML::DocumentFragment.parse(text)
    simple_format truncate(doc.css('p').map(&:text).join("\n\n").to_s, :length => 140)
  end

  def article_remove_h1(text)
    doc = Nokogiri::HTML::DocumentFragment.parse(text)
    doc.css('h1').first.try(:remove)
    doc.to_s
  end
end
