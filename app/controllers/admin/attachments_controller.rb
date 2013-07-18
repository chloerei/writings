class Admin::AttachmentsController < Admin::BaseController
  def index
    @attachments = Attachment.desc(:created_at).page(params[:page]).per(25)
  end
end
