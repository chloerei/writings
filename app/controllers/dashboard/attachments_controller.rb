class Dashboard::AttachmentsController < Dashboard::BaseController
  def show
    @attachment = current_user.attachments.find params[:id]
    redirect_to @attachment.file.url
  end

  def create
    @attachment = current_user.attachments.new attachment_params

    if @attachment.save
      respond_to do |format|
        format.json
      end
    else
      respond_to do |format|
        format.json { render :json => { :message => @attachment.errors.full_messages.join }, :status => 400 }
      end
    end
  rescue CarrierWave::DownloadError
    respond_to do |format|
      format.json { render :json => { :message => I18n.t('errors.messages.fetch_error') }, :status => 400 }
    end
  end

  private

  def attachment_params
    params.require(:attachment).permit(:file, :remote_file_url)
  end
end
