class Importer::Base
  attr_accessor :file, :tmp_path

  def initialize(file, options = {})
    self.file = file
    time = Time.now.to_i
    self.tmp_path = options[:tmp_path] || "#{Rails.root}/tmp/importers/#{time}"

    FileUtils.rm_r tmp_path, :force => true
    FileUtils.mkdir_p tmp_path
  end
end
