class UserMailer < ApplicationMailer

  def loan_created_email(bookLoan)
    @title = bookLoan.book.title
    @reserved_date = bookLoan.book.ongoing_loan.due_date

    mail(to: bookLoan.user.email, subject: "danger - return book")
  end
end