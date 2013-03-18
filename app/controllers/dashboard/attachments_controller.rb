class Dashboard::AttachmentsController < Dashboard::BaseController
  def show
    @attachment = current_user.attachments.find params[:id]
    redirect_to URI.escape(@attachment.file.url)
  end

  def create
    @attachment = current_user.attachments.new attachment_params

    if @attachment.save
      respond_to do |format|
        format.json do
          render :json => {
            :files => [
              {
                :name => @attachment.read_attribute(:file),
                :url  => dashboard_attachment_url(@attachment)
              }
            ]
          }
        end
      end
    else
      respond_to do |format|
        format.json { render :json => { :message => @attachment.errors.full_messages.join }, :status => 400 }
      end
    end
  end

  private

  def attachment_params
    params.require(:attachment).permit(:file)
  end
end
