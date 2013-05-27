class Dashboard::NotesController < Dashboard::BaseController
  before_filter :find_note, :only => [:archive, :destroy, :edit, :update]
  before_filter :require_author, :only => [:destroy, :edit, :update]

  def new
    @article = @space.articles.find_by :token => params[:article_id]
    @notes = @article.notes.opening.where(:element_id => params[:element_id]).includes(:comments)
  end

  def create
    @article = @space.articles.find_by :token => params[:article_id]
    @note = @article.notes.new note_param.merge(:user => current_user, :workspace => @space)
    @note.save
  end

  def archive
    @note.update_attribute :archived, true
  end

  def destroy
    @note.destroy
  end

  def edit
  end

  def update
    @note.update_attributes note_param.slice(:body)
  end

  private

  def find_note
    @note = @space.discussions.find_by :token => params[:id], :_type => 'Note'
  end

  def note_param
    params.require(:note).permit(:body, :element_id)
  end

  def require_author
    if @note.user != current_user
      raise AccessDenied
    end
  end
end
