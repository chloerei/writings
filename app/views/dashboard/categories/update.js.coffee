<% if @category.errors.empty? %>
Turbolinks.visit("<%= dashboard_articles_categorized_path(:category_id => @category) %>")
<% else %>
AlertMessage.show
  type: 'error'
  text: @category.errors.full_messages.join
<% end %>
