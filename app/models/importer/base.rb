class Importer::Base
  def initialize(space, file)
    @space = space
    @file = file

    FileUtils.rm_r tmp_path, :force => true
    FileUtils.mkdir_p tmp_path
  end

  def tmp_path
    "#{Rails.root}/tmp/importers/#{self.class.name.split('::').last.downcase}/#{@space.id}"
  end

  def filter_urlname(urlname)
    if @space.articles.where(:urlname => urlname).any? or urlname !~ /\A[a-zA-Z0-9-]+\z/
      nil
    else
      urlname
    end
  end
end
