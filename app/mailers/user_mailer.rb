class UserMailer < ApplicationMailer
  def loan_created_email(bookLoan)
    @title = bookLoan.book.title
    @due_date = bookLoan.due_date

    mail(to: bookLoan.user.email, subject: "danger - book loaned")
  end
end