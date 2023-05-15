class ChangeBookLoanDueDateToDateTime < ActiveRecord::Migration[7.0]
  def change
    change_column :book_loans, :due_date, :datetime
  end
end
