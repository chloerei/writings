class SystemMailer < ActionMailer::Base
  default :from => "do-not-reply@writings.io"

  def export_task_success(export_task_id)
    @export_task = ExportTask.find export_task_id
    I18n.locale = @export_task.user.locale

    mail(:to => @export_task.user.email,
         :subject => I18n.t('export_task_success_email_subject'))
  end

  def import_task_success(export_task_id)
    @import_task = ImportTask.find export_task_id
    I18n.locale = @import_task.user.locale

    mail(:to => @import_task.user.email,
         :subject => I18n.t('import_task_success_email_subject'))
  end

  def order_payment_success(order_id)
    @order = Order.find order_id
    I18n.locale = @order.space.user.locale

    mail(:to => @order.space.user.email,
         :subject => I18n.t('order_payment_success_email_subject'))
  end

  def order_cancel(order_id)
    @order = Order.find order_id
    I18n.locale = @order.space.user.locale

    mail(:to => @order.space.user.email,
         :subject => I18n.t('order_cancel_email_subject'))
  end

  def password_reset(user_id)
    @user = User.find user_id
    I18n.locale = @user.locale

    mail(:to => @user.email,
         :subject => I18n.t('password_reset_email_subject'))
  end
end
