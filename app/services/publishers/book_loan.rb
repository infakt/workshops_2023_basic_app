module Publishers
  class BookLoan
    def initialize(data)
      @data = data
    end

    def publish
      ::Publishers::Application.new(
        routing_key: 'book_loan',
        exchange_name: 'basic_app',
        message: { data: data }
      ).perform
    end

    attr_reader :data
  end
end
