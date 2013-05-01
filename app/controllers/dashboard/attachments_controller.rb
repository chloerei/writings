class Dashboard::AttachmentsController < Dashboard::BaseController
  def index
    @attachments = current_user.attachments.desc(:created_at).page(params[:page]).per(50)
  end

  def show
    @attachment = current_user.attachments.find params[:id]
    redirect_to @attachment.file.url
  end

  def create
    @attachment = current_user.attachments.new attachment_params.merge(:user => current_user)

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
    @attachment = current_user.attachments.find params[:id]
    @attachment.destroy

    respond_to do |format|
      format.js
    end
  end

  private

  def attachment_params
    params.require(:attachment).permit(:file, :remote_file_url)
  end
end
