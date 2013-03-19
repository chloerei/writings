json.files [@attachment] do |attachment|
  json.name attachment.read_attribute(:file)
  json.url dashboard_attachment_url(attachment)
end

json.storage_status do
  json.limit current_user.storage_limit
  json.used current_user.storage_used
  json.limit_human_size number_to_human_size(current_user.storage_limit)
  json.used_human_size number_to_human_size(current_user.storage_used)
end
