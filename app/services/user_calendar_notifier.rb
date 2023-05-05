require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets'

class UserCalendarNotifier
  CALENDAR_ID = 'primary'.freeze

  def get_google_calendar_client(user)
    client = Google::Apis::CalendarV3::CalendarService.new
    return unless user.present? && user.token.present? && user.refresh_token.present?

    secrets = Google::APIClient::ClientSecrets.new({
                                                     'web' => {
                                                       'access_token' => user.token,
                                                       'refresh_token' => user.refresh_token,
                                                       'client_id' => A9n.google_client_id,
                                                       'client_secret' => A9n.google_client_secret
                                                     }
                                                   })

    begin
      client.authorization = secrets.to_authorization
      client.authorization.grant_type = 'refresh_token'
    rescue StandardError => e
      Rails.logger.debug e.message
    end
    client
  end

  def get_event(book)
    {
      summary: "Oddać książkę: #{book.title}",
      description: "Mija termin oddania książki: #{book.title}",
      start: {
        date_time: two_week_from_now.to_datetime.to_s
      },
      end: {
        date_time: (two_week_from_now + 1.hour).to_datetime.to_s
      }
    }
  end

  def two_week_from_now
    Time.zone.now + 14.days
  end

  def insert_event(user, book)
    client = get_google_calendar_client(user)
    client.insert_event(CALENDAR_ID, get_event(book))
  end
end
