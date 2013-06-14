require 'test_helper'

class ArticleExporterTest < ActiveSupport::TestCase
  def setup
    @article = create :article
    @article.body = <<-EOF
    <h1>title</h1>
    <p>content</p>
    <p>
      <img src="http://localhost:3000/assets/rails.png">
      <img src="http://localhost:3000/assets/rails.png">
    </p>
    EOF

    @exporter = ArticleExporter.new(@article)
  end

  test "should tmp_path" do
    assert_equal "#{Rails.root}/tmp/exporters/article/#{@article.id}", @exporter.tmp_path
  end

  test "prepare" do
    @exporter.prepare
    assert File.exists?(@exporter.tmp_path)
    assert File.exists?("#{@exporter.tmp_path}/images")
  end

  test "dump_body" do
    @exporter.dump_body
    assert File.exists?("#{@exporter.tmp_path}/body.html")
    assert_equal @article.body, File.open("#{@exporter.tmp_path}/body.html").read
  end

  test "fetch_images" do
    @exporter.fetch_images
    assert_equal 2, Dir.glob("#{@exporter.tmp_path}/images/*").count
  end

  test "build_docx" do
    @exporter.build_docx
    assert File.exists?("#{@exporter.tmp_path}/output.docx")
  end

  test "build_odt" do
    @exporter.build_odt
    assert File.exists?("#{@exporter.tmp_path}/output.odt")
  end
end
