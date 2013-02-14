class AddDueAtStartToPaymentSchedule < ActiveRecord::Migration
  def change
    add_column :payment_schedules, :final_due_at_start, :boolean
  end
end
