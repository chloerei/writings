require 'open-uri'

connection = Fog::Storage.new(
  :provider              => 'AWS',
  :aws_access_key_id     => APP_CONFIG['s3']['aws_access_key_id'],
  :aws_secret_access_key => APP_CONFIG['s3']['aws_secret_access_key'],
  :region                => APP_CONFIG['s3']['region']
)

directory = connection.directories.new(
  :key => APP_CONFIG['s3']['fog_directory']
)

Attachment.each do |attachment|
  begin
    puts "deleting #{attachment.file_name}"
    directory.files.new(:key => "attachments/#{attachment.id}/#{attachment.file_name}").destroy
    directory.files.new(:key => "attachments/#{attachment.id}/thumb_#{attachment.file_name}").destroy
  rescue => e
    puts e
  end
end
