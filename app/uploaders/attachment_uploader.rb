# encoding: utf-8

class AttachmentUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  if Rails.env.development?
    storage :file

    def store_dir
      "uploads/#{model.class.to_s.underscore.pluralize}/#{model.id}/#{model.token}"
    end
  else
    storage :fog

    def store_dir
      "#{model.class.to_s.underscore.pluralize}/#{model.id}/#{model.token}"
    end
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  version :thumb do
    process :resize_to_limit => [200, 200]
  end
end
