session = Mongoid::Sessions.default
database = session[:users].database.name
session.with(:database => "admin") do |s|
  s.command({ :renameCollection => "#{database}.users", :to => "#{database}.spaces", :dropTarget => true })
end

Space.update_all :_type => 'User'

Article.all.each do |article|
  article.rename :user_id, :space_id
end

Category.all.each do |category|
  category.rename :user_id, :space_id
end

Attachment.asc(:_id).all.each do |attachment|
  attachment.update_attribute :space_id, attachment.user_id
end
