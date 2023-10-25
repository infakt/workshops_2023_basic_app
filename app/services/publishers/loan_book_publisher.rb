class LoanBookPublisher
  def initialize(message_content)
    @message_content = message_content
  end

  def publish
    Application.new(key: 'book_loans_app', name: 'book_loander', message: @message_content).perform
  end
end