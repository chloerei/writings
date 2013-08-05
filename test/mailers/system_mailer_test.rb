require 'test_helper'

class SystemMailerTest < ActionMailer::TestCase
  test "export_task_success" do
    export_task = create :export_task

    assert_difference "ActionMailer::Base.deliveries.count" do
      SystemMailer.export_task_success(export_task.id).deliver
    end
  end

  test "import_task_success" do
    import_task = create :import_task

    assert_difference "ActionMailer::Base.deliveries.count" do
      SystemMailer.import_task_success(import_task.id).deliver
    end
  end

  test "order_payment_success email" do
    order = create :order
    assert_difference "ActionMailer::Base.deliveries.count" do
      SystemMailer.order_payment_success(order.id).deliver
    end
  end

  test "order_cancel email" do
    order = create :order
    assert_difference "ActionMailer::Base.deliveries.count" do
      SystemMailer.order_cancel(order.id).deliver
    end
  end

  test "password_reset email" do
    user = create :user
    user.generate_password_reset_token
    assert_difference "ActionMailer::Base.deliveries.count" do
      SystemMailer.password_reset(user.id).deliver
    end
  end
end
