class FileUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "#{Rails.root}/data/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end
