CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => APP_CONFIG['s3']['aws_access_key_id'],
    :aws_secret_access_key  => APP_CONFIG['s3']['aws_secret_access_key'],
    :region                 => APP_CONFIG['s3']['region']
  }
  config.fog_directory = APP_CONFIG['s3']['fog_directory']
  config.fog_public = true
  config.cache_dir = "#{Rails.root}/tmp/uploads"
  config.ignore_download_errors = false
end

CarrierWave::SanitizedFile.sanitize_regexp = /[^[:word:]\.\-\+ ]/
