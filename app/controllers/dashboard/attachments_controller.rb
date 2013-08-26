class Dashboard::AttachmentsController < Dashboard::BaseController
  def index
    @attachments = @space.attachments.desc(:created_at).page(params[:page]).per(25)
  end

  def create
    @attachment = @space.attachments.new attachment_params.merge(:user => current_user)

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

  def destroy
    @attachment = @space.attachments.find params[:id]
    @attachment.destroy
  end

  private

  def attachment_params
    params.require(:attachment).permit(:file, :remote_file_url)
  end
end
