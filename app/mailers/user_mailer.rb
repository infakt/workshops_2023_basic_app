class UserMailer < ApplicationMailer
  def loan_created_email(book_loan)
    @book_title = book_loan.book.title
    @due_date = book_loan.due_date

    mail(to: book_loan.user.email, subject: 'Your book loan was created successfully')
  end

  def due_date_notification_email(book_loan)
    @book_title = book_loan.book.title
    @due_date = book_loan.due_date

    mail(to: book_loan.user.email, subject: 'Your book loan period ends tomorrow')
  end

    def due_date_notification_cron_email(book_loan)
    @book_title = book_loan.book.title
    @due_date = book_loan.due_date

    mail(to: book_loan.user.email, subject: 'Your book loan period ends tomorrow(CRON)')
  end
end
