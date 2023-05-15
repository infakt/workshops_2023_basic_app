class LoanCreatedJob
  include Sidekiq::Job

  def perform(id)
    book_loan = BookLoan.find(id)

    UserMailer.loan_created_email(book_loan).deliver_later
  end
end
