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
    puts "parsing #{attachment.file.url}"
    attachment.save
    directory.files.create(
      :key => "attachments/#{attachment.id}/#{attachment.token}/#{attachment.file_name}",
      :body => open(attachment.file.url),
        :public => true
    )
    directory.files.create(
      :key => "attachments/#{attachment.id}/#{attachment.token}/thumb_#{attachment.file_name}",
      :body => open(attachment.file.thumb.url),
        :public => true
    )
  rescue => e
    puts e
  end
end
