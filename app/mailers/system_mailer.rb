class SystemMailer < ActionMailer::Base
  default :from => "do-not-reply@writings.io"

  def export_task_success(export_task_id)
    @export_task = ExportTask.find export_task_id

    mail(:to => @export_task.user.email,
         :subject => I18n.t('export_task_success_email_subject'))
  end

  def import_task_success(export_task_id)
    @import_task = ImportTask.find export_task_id

    mail(:to => @import_task.user.email,
         :subject => I18n.t('import_task_success_email_subject'))
  end

  def order_payment_success(order_id)
    @order = Order.find order_id

    mail(:to => @order.user.email,
         :subject => I18n.t('order_payment_success_email_subject'))
  end

  def order_cancel(order_id)
    @order = Order.find order_id

    mail(:to => @order.user.email,
         :subject => I18n.t('order_cancel_email_subject'))
  end
end
