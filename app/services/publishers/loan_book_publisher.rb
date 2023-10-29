
module Publishers
  class LoanBookPublisher
    def initialize(message_content)
      @message_content = message_content
    end

    def publish
      ::Publishers::Application.new(key: 'book_loans_app', name: 'book_loaner', message_content: @message_content).perform
    end
  end
end