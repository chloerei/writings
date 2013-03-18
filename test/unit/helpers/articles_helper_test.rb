require 'test_helper'

class ArticlesHelperTest < ActionView::TestCase
  test "should convert public attachment link" do
    attachment = create :attachment
    body = %Q[<img src="#{dashboard_attachment_url(attachment, :host => APP_CONFIG['host'])}">]
    result = convert_attachment_url(body)
    puts result
    assert (result =~ /aws/)
  end
end
