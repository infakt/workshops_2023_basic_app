class DueDateNotificationsJob
  include Sidekiq::Job

  def perform
    # for notification testing purposes
    # BookLoan.where(status: 'checked_out', due_date: Time.current..Time.current + 4.minutes).each do |book_loan|
    BookLoan.where(status: 'checked_out', due_date: Date.tomorrow).each do |book_loan|
      UserMailer.notification_email(book_loan).deliver_later
    end
  end
end
