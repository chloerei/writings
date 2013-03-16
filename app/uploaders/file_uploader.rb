# encoding: utf-8

class FileUploader < CarrierWave::Uploader::Base
  if Rails.env.development?
    storage :file

    def store_dir
      "uploads/#{model.class.to_s.underscore.pluralize}/#{model.id}"
    end
  else
    storage :fog

    def store_dir
      "#{model.class.to_s.underscore.pluralize}/#{model.id}"
    end
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
