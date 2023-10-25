require 'bunny'

class Application
  def initialize(message_content: 'message_content', name: 'name', key: 'key')
    @message_content = message_content
    @name =  name
    @key = key
  end
  
  def perform
    connection.start
    channel = connection.create_channel
    exchange = channel.direct(@name)
    exchange.publish(@message_content.to_json, routing_key: @key)
    connection.close
  end

  private

  def connection_options
    {
      host: "localhost",
      port: "5672",
      vhost: "/",
      username: "guest",
      password: "guest"
    }
  end

  def connection
    @connection ||= Bunny.new(connection_options)
  end 
end