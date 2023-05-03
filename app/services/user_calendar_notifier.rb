require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets.rb'

class UserCalendarNotifier
  include ActiveSupport::Concern

  def get_google_calendar_client(current_user)
    client = Google::Apis::CalendarV3::CalendarService.new
    return unless (current_user.present? && current_user.token.present? && current_user.refresh_token.present?)

    secrets = Google::APIClient::ClientSecrets.new({
      "web" => {
        "access_token" => current_user.token,
        "refresh_token" => current_user.refresh_token,
        "client_id" => A9n.google_client_id,
        "client_secret" => A9n.google_client_secret
      }
    })
    begin
      client.authorization = secrets.to_authorization
      client.authorization.grant_type = "refresh_token"

    rescue => e
      puts e.message
    end
    client
  end

  def add_event_to_calendar(current_user)
    client = get_google_calendar_client(current_user)
    client.quick_add_event('reader_reminder', 'testowe wydarzenie')
  end
end