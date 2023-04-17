module Publishers
  class Loan
    def initialize(data)
      @data = data
    end

    def publish
      ::Publishers::Application.new(
        routing_key: 'basic_app.loan',
        exchange_name: 'basic_app',
        message: { data: data }
      ).perform
    end

    attr_reader :data
  end
end
