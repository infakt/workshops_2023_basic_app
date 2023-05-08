# Integracja aplikacji kalendarzem Google

## Cel zadania

Chcemy, aby w naszej aplikacji użytkownik mógł logować się za pomocą konta Google Gmail oraz aby w kalendarzu Google tego użytkownika pojawiało się wydarzenie przypominające o teerminie oddania książki wypożyczonej w naszej aplikacji.

## Dwa etapy zadania

1. Umożliwienie logowania się w aplikacja za pomocą konta Google.
2. Utworzenie eventu w kalendarzu Google zalogowanego użytkownika:
 - event pojawia się w kalendarzu tu po akcji wypożyczenia książki,
 - event widoczny jest w kalendarzu w dacie sugerowanego terminu oddania książki, umownie ustalamy to na dwa tygodnie od daty wypożyczenia.

## Działamy!

## Etap 1 - pozyskanie klucza API

1. Najpierw pozyskamy credentiale dla klienta OAuth, bo aktywowane są po około 5 minutach więc aby nie czekać potem to najpierw uzyskamy je a nastepnie przejdziemy do pracy z kodem.
2. Aby to wykonac potrzebujemy posiadać konto Google, jeśli nie chcemy korzystać z naszego oficjalnego konta, możemy stworzyć sobie nowe/do celów projektu konto Gmail, zajmie to mniej niz minutę, moze się to dodatkowo przydać w kolejnym etapie, aby dodać konto testowe dla kalendarza więc warto stworzyć.
3. Przechodzimy do https://console.developers.google.com a tam:
    - wybierz projekt a tam dodaj nowy projekt, nadajemy mu nazwę i zapisujemy, przechodzimy do tego projektu (ponieważ automatycznie po stworzeniu projektu nie przenosi nas do niego jeśli mamy też inne),
    - ustawiamy "Ekran zgody OAuth" i klikamy ponownie "Utwórz dane logowania" a tam "Identyfikator klienta OAuth"
    - jako stronę główną aplikacji ustawiamy http://localhost:3000/users/sign_in
    - w sekcji "Ekran zgody OAuth" dodajemy tez testowych userów, najlepiej dwa nasze konta Gmail (mozna tu uzyć tego nowo stworzonego wyzej)
    - po dokonaniu ustawień w "Ekran zgody OAuth" przechodzimy do sekcji "Dane logowania"
    - typ aplikacji: wybbieramy "Aplikacja internetowa"
    - jako "Autoryzowany indentyfikator URI przekierowania" ustawiamy http://localhost:3000/users/auth/google_oauth2/callback
    - zatwierdzamy i otrzymujemy odpowiednie credentiale dla utworzonego klienta OAuth
4. Mamy juz wszystkie potrzebne credentiale więc zaczynamy pracę z kodem. Wychodzimy z głównego brancha `main` i tworzymy nowy branch dla tych zmian.
5. Jeśli działasz na branchu, na którym nie masz dodanego gemu A9n to dodaj go analogicznie jak w zadaniu o API pogodowym. Przyda się do bezpiecznego zapisania naszych danych autoryzujących. Pamiętaj o dodaniu zmian w `.gitignore` dla pliku `config/configuration.yml`
6. Zaczynamy od dodania dwóch gemów:
`gem 'omniauth-google-oauth2'` - realizuje autentykację z kontem Google z wykorzystaniem OAuth2
`gem 'omniauth-rails_csrf_protection'` - dla zabezpieczenia podatności bezpieczeństwa (do poczytania tu https://github.com/cookpad/omniauth-rails_csrf_protection)
i uruchamiamy `bundle`
7. W pliku `config/configuration.yml.example` dodajemy nowe klucze:
```
defaults:
  google_client_id: '__your_client_id__'
  google_client_secret: '__your_client_secret__'
  app_host: 'http://localhost:3000'
```
a w pliku `config/configuration.yml` zapisujemy nasze prawdziwe dane.

8. Postępujemy zgodnie z instrukcją dla gema https://github.com/zquestz/omniauth-google-oauth2 i dodajemy odpowiednie zmiany w aplikacji (uwaga: uwzględniamy róznice w konfiguracji w przypadku, gdy korzystamy z Devise'a, a u nas korzystamy):
 - w initializerze `config/initializers/devise.rb` dodajemy zapis: `  config.omniauth :google_oauth2, A9n.google_client_id, A9n.google_client_secret, {}`
 - definiujemy scieżke dla callbacków w `config/routes.rb`: `devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }`
 - w modelu `User` powiązujemy lub tworzymy usera:
   ```  
   def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    unless user
      user = User.create(
       email: data['email'],
       password: Devise.friendly_token[0,20]
      )
    end
    user
  end
  ```
 oraz upewniamy się, że nasz model jest `omniauthable` czyli dodajemy zapis `devise :omniauthable, omniauth_providers: [:google_oauth2]`
 - następnie musimy stworzyć odpowiednio kontroler dla callbacków `app/controllers/users/omniauth_callbacks_controller.rb`:
 ```
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect @user, event: :authentication
    else
      session['devise.google_data'] = request.env['omniauth.auth'].except('extra')
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end
end
```
9. Teraz jeszcze potrzebujemy dodać ładny button, który będzie przenosił nas do logowania za pomoca konta Google. Stąd możemy pobrać zestaw oryginalnych buttonów https://developers.google.com/identity/branding-guidelines?hl=pl, dla uproszczenia wystarczy nam jeden, który dodajemy do katalogu assets `app/assets/images/btn_google_signin_dark_normal_web.png`.
10. Ostatnia zmiana dotyczy już widoku strony rejestracji/logowania, w tym miejscu `app/views/devise/shared/_links.html.erb` zamieniamy linię `<%= button_to "Sign in with #{OmniAuth::Utils.camelize(provider)}", omniauth_authorize_path(resource_name, provider), data: { turbo: false } %><br />`
na
    ```
    <%= form_for 'Login',
      url: omniauth_authorize_path(resource_name, provider),
      method: :post, 
      data: { turbo: false } do |f| %>
      <%= f.submit "Log in with #{provider.to_s.titleize}", type: "image", src: url_for("/assets/btn_google_signin_dark_normal_web.png") %>
    <% end %>
    ```
11. Czas na próbę generalną. Restartujemy serwer i korzystając z dodanego przez nas buttona sprawdzamy czy jesteśmy w stanie zalogować się do aplikacji z wykorzystaniem konta Google.


## Etap 2 - wdrożenie danych pogodowych w aplikacji

1. Zaczynamy od włączenia Google Calendar API. Wchodzimy na https://console.developers.google.com a tam:
 - pamiętamy, aby mieć zaklikany odpowiedni projekt z listy, wybieramy ten, na którym realizujemy nasz projekt (załozony w Etapie 1)
 - przechodzimy do sekcji "Biblioteka"
 - znajdujemy na liście "Google Calendar API", klikamy w to i włączamy ten interfejs API, klikamy "Włącz"
 - bedziemy go potem mogli podejrzeć w sekcji "Włączone interfejsy API..."
2. Dokumentacja API kalendarza Google znajduje się tu https://developers.google.com/calendar/api/v3/reference?hl=pl
3. Upewniamy sie, ze jesteśmy na branchu dla tego zadania i dalej działamy z kodem.
4. Dodajemy gema w Gemfile ułatwiającego korzystanie z Google Calendar API i uruchamimy `bundle`:
`gem 'google-api-client', require: 'google/apis/calendar_v3'`
5. Robimy migrację dla modelu `User` dodającą dodatkowe pole, w których zapiszemy dodatkowe informacje związane z autoryzacją poprzez OAuth"
```
class AddOauthFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :token, :string
    add_column :users, :refresh_token, :string
  end
end
```
i odpalamy `rake db:migrate`
6. Dodany w etapie 1 zapis w `config/initializers/devise.rb` modyfikujemy uzupełniając pusty dotychczas hash o elementy potrzebne do integracji z kalendarzem:
```
  config.omniauth :google_oauth2, A9n.google_client_id, A9n.google_client_secret, {
    access_type: "offline", 
    prompt: "consent",
    select_account: true,
    scope: 'userinfo.email, calendar'
  }
```
7. Modyfikujemy metodę w modelu `User` szukającą lub tworzącą usera
```  
  def self.from_omniauth(access_token)
    find_or_create_by(provider: access_token.provider, email:
      access_token.info.email) do |user|
      user.provider = access_token.provider
      user.uid = access_token.uid
      user.email = access_token.info.email
      user.password = Devise.friendly_token[0, 20]
      user.token = access_token.credentials.token
      user.refresh_token = access_token.credentials.refresh_token
      user.save!
    end
  end
  ```
8. Przed nami teraz zadanie stworzenia clienta API oraz metody, która spowoduje dodanie eventu w kalendarzu usera. Dla celów zadania ustalmy sobie, że maksymalny termin oddania pożyczonej książki to 2 tygodnie.
Zatem postaramy się tak skonstruować naszą akcję, aby dodawała event w dacie 2 tygodnie od dziś o tej samej godzinie. Czas trwania eventu to 1h.
Stwórzmy zatem serwis, który zajmie się tym wszystkim `app/services/user_calendar_notifier.rb`.
 - na początek ustalmy też, że event bedziemy dodawać zawsze w głównym kalendarzu user, dodajmy więc stałą `  CALENDAR_ID = 'primary'.freeze`
 - stwórzmy teraz metodę, która zwróci nam klienta API dla danego usera `get_google_calendar_client(user)`
 Samego klienta tworzymy w ten sposób `client = Google::Apis::CalendarV3::CalendarService.new`.
 Warto zabezpieczyć jeśli nie ma usera lub nie posiada on tokena i refres_tokena:
 `return unless user.present? && user.token.present? && user.refresh_token.present?`
 Przygotujmy zestaw credentiali dla usera:
 ```
 secrets = Google::APIClient::ClientSecrets.new({
                                                     'web' => {
                                                       'access_token' => user.token,
                                                       'refresh_token' => user.refresh_token,
                                                       'client_id' => A9n.google_client_id,
                                                       'client_secret' => A9n.google_client_secret
                                                     }
                                                   })
```
i przypiszmy je do naszego klienta:
```
client.authorization = secrets.to_authorization
client.authorization.grant_type = 'refresh_token'
```
warto tez zabezpieczyć się na wypadek, gdyby coś poszło nie tak:
```
    begin
      client.authorization = secrets.to_authorization
      client.authorization.grant_type = 'refresh_token'
    rescue StandardError => e
      Rails.logger.debug e.message
    end
```
Na koniec zwracamy z tej motody klienta, czyli po prostu `client`.

Aby nasze zmiany zadziałały warto pamiętać o wywołaniu przed zdefiniowaniem klasy:
```
require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets'
```

9. Kolejnym krokiem będzie przygotowanie danych dla naszego eventu, jaki będziemy chcieli stworzyc w kalendarzu:
```
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
```
Aby nieco uprościć zapis kodu mozna skorzystać ze zdefiniowania terminu oddania ksiązki:
```
  def two_week_from_now
    Time.zone.now + 14.days
  end
```
10. Na koniec w naszym serwisie musimy zdefiniować działanie metody, która doda event do kalendarza. Skorzystamy tu z metody wg dokumentacji Google Calendar API `insert_event` do której jako parametry podajemy id kalendarza oraz event:
```
  def insert_event(user, book)
    client = get_google_calendar_client(user)
    client.insert_event(CALENDAR_ID, get_event(book))
  end
```
11. Tak stworzoną akcję nalezy teraz podpiąć w odpowiednim miejscu aplikacji, które odpowiada za wypozyczenie ksiązki. Bedzie to akcja `create` w kontrolerze `app/controllers/book_loans_controller.rb`.
12. Tworzymy w tym kontrolerze metodę odwołującą się do metody `insert_event(user, book)` z naszego serwisu z klientem API:
```
  def notice_calendar(book)
    UserCalendarNotifier.new.insert_event(current_user, book)
  end
```
i wywołujemy ją w metodzie `create` kontrolera odpowiadającego za wypozyczenie w sekcji, która kończy się sukcesem, wystarczy zatem, ze wywołamy tam `notice_calendar(book)`.
13. Sprawdźmy teraz czy nasze zmiany zadziałały. Zalogujmy się do aplikacji kontem Google a następnie kliknijmy na button "Loan" przy jednej z ksiązek. W kalendarzu Google sprawdźmy czy w dacie za dwa tygodnie od dziś pojawiło się nowe wydarzenie. Jeśli tak to gratulacje, właśnie zakończyłeś/aś zadanie!

## Zadanie dodatkowe

1. Spróbuj zapisać w bazie id eventu tworzonego w kalendarzu i w momencie oddania ksiązki usuń event z kalendarza.
