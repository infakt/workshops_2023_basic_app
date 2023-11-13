class UserMailer < ApplicationMailer
  def loan_created_email(book_load)
    @title = book_load.book.title
    @date = book_load.created_at
    @due_date = book_load.due_date
    @email = book_load.user.email
    @email_subject = "New action in your account"
    mail(to: @email, subject: @email_subject)
  end

  def due_date_notification_email
    @title = book_load.book.title
    @due_date = book_load.due_date
    @email = book_load.user.email
    @email_subject = "ALERT"
    mail(to: @email, subject: @email_subject)
  end
end
