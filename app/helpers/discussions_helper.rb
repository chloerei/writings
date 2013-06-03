module DiscussionsHelper
  def dashboard_discussion_path(discussion)
    case discussion
    when Topic
      dashboard_topic_path :id => discussion
    when Note
      edit_dashboard_article_path :id => discussion.article, :note_id => discussion, :anchor => discussion.element_id
    end
  end
end
