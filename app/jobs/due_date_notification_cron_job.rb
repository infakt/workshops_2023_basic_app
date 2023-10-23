class DueDateNotificationCronJob
  include Sidekiq::Job

  def perform
    BookLoan.checked_out.where(due_date: Date.tomorrow).each do |book_loan|
      UserMailer.due_date_notification_cron_email(book_loan).deliver_now
    end
  end
end
