# encoding: utf-8

class FileUploader < CarrierWave::Uploader::Base
  storage :fog

  def store_dir
    "#{model.class.to_s.underscore.pluralize}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
