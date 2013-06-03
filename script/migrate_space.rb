Rails::Mongoid.remove_indexes

session = Mongoid::Sessions.default
database = session[:users].database.name
session.with(:database => "admin") do |s|
  s.command({ :renameCollection => "#{database}.users", :to => "#{database}.spaces", :dropTarget => true })
end

Space.update_all :_type => 'User'

Article.asc(:_id).all.each do |article|
  article.rename :user_id, :space_id
end

Category.asc(:_id).all.each do |category|
  category.rename :user_id, :space_id
end

Attachment.asc(:_id).all.each do |attachment|
  attachment.update_attribute :space_id, attachment.user_id
end

User.asc(:_id).all.each do |user|
  user.full_name = user["profile.name"]
  user.description = user["profile.description"]
  user.save
  user.unset(:profile)
end

Rails::Mongoid.create_indexes

def convert_attachment_url(text, space)
  doc = Nokogiri::HTML::DocumentFragment.parse(text)
  doc.css('img').each do |img|
    if r = %r|http://writings.io/attachments/(?<id>\w+)|.match(img['src'])
      if attachment = space.attachments.where(:id => r[:id]).first
        img['src'] = attachment.file.url
        puts img['src']
      end
    end
  end
  doc.to_s
end

Article.asc(:_id).all.each do |article|
  article.update_attribute :body, convert_attachment_url(article.body, article.space)
end
