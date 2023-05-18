class UserMailer < ApplicationMailer
  def notification_email(book_loan)
    @title = book_loan.book.title
    @due_date = book_loan.due_date

    mail(to: book_loan.user.email, subject: 'Your book loan period ends tomorrow')
  end
end
