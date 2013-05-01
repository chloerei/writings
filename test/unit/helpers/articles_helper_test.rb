require 'test_helper'

class ArticlesHelperTest < ActionView::TestCase
  test "should convert public attachment link" do
    attachment = create :attachment
    body = %Q[<img src="#{dashboard_attachment_url(attachment, :host => APP_CONFIG['host'])}">]
    result = convert_attachment_url(body, attachment.space)
    assert (result =~ /aws/)

    result = convert_attachment_url(body, create(:user))
    assert (result !~ /aws/)
  end
end
