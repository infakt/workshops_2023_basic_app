class LoanCreatedJob < ActiveJob::Base
  def perform(book_loan)
    UserMailer.loan_created_email(book_loan).deliver_later
  end
end
