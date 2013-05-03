json.files [@attachment] do |attachment|
  json.name attachment.read_attribute(:file)
  json.url dashboard_attachment_url(:id => attachment)
end

json.storage_status do
  json.limit @space.storage_limit
  json.used @space.storage_used
  json.limit_human_size number_to_human_size(@space.storage_limit)
  json.used_human_size number_to_human_size(@space.storage_used)
end
