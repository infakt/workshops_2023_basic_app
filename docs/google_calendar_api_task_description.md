# Integracja aplikacji kalendarzem Google

## Cel zadania

Chcemy, aby w naszej aplikacji użytkownik mógł logować się za pomocą konta Google Gmail oraz aby w kalendarzu Google tego użytkownika pojawiało się wydarzenie przypominające o terminie oddania książki wypożyczonej w naszej aplikacji.

## Dwa etapy zadania

1. Umożliwienie logowania się w aplikacja za pomocą konta Google.
2. Utworzenie eventu w kalendarzu Google zalogowanego użytkownika:
 - event pojawia się w kalendarzu tuż po akcji wypożyczenia książki,
 - event widoczny jest w kalendarzu w dacie sugerowanego terminu oddania książki, umownie ustalamy to na dwa tygodnie od daty wypożyczenia.

## Działamy!

## Etap 1 - logowanie za pomoca konta Google

1. Najpierw pozyskamy credentiale dla klienta OAuth, bo aktywowane są po około 5 minutach więc aby nie czekać potem to najpierw uzyskamy je a nastepnie przejdziemy do pracy z kodem.
2. Aby to wykonać potrzebujemy posiadać konto Google, jeśli nie chcemy korzystać z naszego oficjalnego konta, możemy stworzyć sobie nowe/do celów projektu konto Gmail, zajmie to mniej niż minutę, może się to dodatkowo przydać w kolejnym etapie, aby dodać konto testowe dla kalendarza więc warto stworzyć.
3. Przechodzimy do https://console.developers.google.com a tam:
<ul>
  <li>Po wejściu na stronę dla developerów wyrażamy zgodę i zatwierdzamy.</li>
  <li>Klikamy "Wybierz projekt".</li>
  <li>Klikamy "Nowy projekt".</li>
  <li>Nadajemy nazwę projektu "rorproject" (w polu Lokalizacja zostawiamy "Brak organizacji") i klikamy "Utwórz".</li>
  <li>Upewniamy się, że mamy wskazany aktualnie nasz nowy projekt w rozwijanej liście projektów (obok loga Google Cloud).</li>
  <li>Wchodzimy z lewego menu w "Ekran zgody OAuth" i zaznaczamy User Type jako "zewnętrzny" i klikamy "Utwórz".</li>
  <li>W kolejnym kroku wypełniamy nazwę aplikacji jako "workshops_2023_basic_app", adres email dla użytkowników potrzebujacych pomocy (Twój email konta, które przeznaczyłeś do pracy z projektem), logo zostawiamy puste, w polu "Strona główna aplikacji" wstawiamy "http://localhost:3000/users/sign_in", pozostałe linki zostawiamy puste. Wypełniamy jeszcze nasz email w polu „Dane kontaktowe deweplopera i klikamy "Zapisz i kontynuuj".</li>
  <li>Zostaniemy przeniesieni do kroku "Zakresy", nic tu nie zmieniamy i klikamy "Zapisz i kontynuuj".</li>
  <li>Zostaniemy przeniesieni do kroku "Użytkownicy testowi", gdzie klikając na "Add users" dodajemy adresy email naszych kont testowych. Po ich dodaniu klikamy „Zapisz i kontynuuj”.</li>
  <li>Zostaniemy przeniesieni na stronę z podsumowaniem, gdzie w razie pomyłki możemy wyedytować dane. Klikamy "Powrót do panelu".</li>
  <li>Z bocznego panelu przechodzimy do sekcji "Dane logowania" i klikamy "Utwórz dane logowania" gdzie wybieramy "Identyfikator klienta OAuth".</li>
  <li>W polu "Typ aplikacji" wybieramy "Aplikacja internetowa", w polu "Nazwa" wpisujemy "Warsztaty inFakt 2023", w sekcji "Autoryzowane indetyfikatory URI przekierowania" klikamy button "Dodaj URI" i podajemy tam adres "http://localhost:3000/users/auth/google_oauth2/callback", zatwierdzamy klikając button "Utwórz".</li>
  <li>Pojawi się nam popup z potwierdzeniem, że "Klient OAuth został utworzony" oraz z danymi logowania. Będą nam one potrzebne w konfiguracji projektu więc należy je zapisać, można żyć opcji "Pobierz JSON".</li>
</ul>

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
 - definiujemy ścieżkę dla callbacków w `config/routes.rb` (aktualizujemy aktualny wiersz z `devise_for :users` a nie dodajemy nowego): `devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }`
 - w modelu `User` powiązujemy lub tworzymy usera:

```ruby
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
```ruby
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


## Etap 2 - integracja z kalendarzem Google

1. Zaczynamy od włączenia Google Calendar API. Wchodzimy na https://console.developers.google.com a tam:
 - pamiętamy, aby mieć zaklikany odpowiedni projekt z listy, wybieramy ten, na którym realizujemy nasz projekt (załozony w Etapie 1)
 - przechodzimy do sekcji "Biblioteka" (ang: Library)
 - znajdujemy na liście "Google Calendar API", klikamy w to i włączamy ten interfejs API, klikamy "Włącz" (ang: Enabled)
 - bedziemy go potem mogli podejrzeć w sekcji "Włączone interfejsy API..." (ang: Enabled APIs & services)
2. Dokumentacja API kalendarza Google znajduje się tu https://developers.google.com/calendar/api/v3/reference?hl=pl
3. Zanim zaczniemy modyfikować kod i testować zmiany dobrze jest usunąc lokalnie z konsoli usera z naszym adresem email, którym testowaliśmy logowanie przez kontro Google.
Ponieważ nie ma on ustawionego tokena i refresh_tokena pojawi nam się błąd w dalszych etapach. Moglibyśmy podjąc się uzupełnienia tych danych, ale na tym etapie upraszczamy działanie, aby móc skupic sie na kontynuacji zadania.
Uruchamiamy zatem konsolę `rails c` i znajdujemy naszego usera `user = User.find_by(email: ...)` i usuwamy go `user.destroy`.
Upewniamy się, że jesteśmy na branchu dla tego zadania i dalej działamy z kodem.
4. Dodajemy gema w Gemfile ułatwiającego korzystanie z Google Calendar API i uruchamimy `bundle`:
`gem 'google-api-client', require: 'google/apis/calendar_v3'`
5. Robimy migrację dla modelu `User` dodającą dodatkowe pole, w których zapiszemy dodatkowe informacje związane z autoryzacją poprzez OAuth
Skorzystaj klasycznie z `rails g migration` - timestamp będzie potrzebny dla "prawidłowej" migracji<br>
```ruby
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
```ruby
  config.omniauth :google_oauth2, A9n.google_client_id, A9n.google_client_secret, {
    access_type: "offline", 
    prompt: "consent",
    select_account: true,
    scope: 'userinfo.email, calendar'
  }
```
7. Modyfikujemy metodę w modelu `User` szukającą lub tworzącą usera:
```ruby
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
Docelowo jego zadaniem będzie dodanie eventu dla danej książki, dla danego usera, w dacie 2 tygodnie od dziś o tej samej godzinie. Czas trwania eventu to 1h.

Żeby to osiągnąć będziemy potrzebowali:
<ul>
<li>Przekazać do naszego serwisu usera oraz książkę (żeby wiedzieć komu i jaki event dodać)</li>
<li>stworzyć metodę, która buduje komunikację z kalendarzem (API Google Calendar)</li>
<li>Określić parametry eventu, który będziemy chcieli przekazać do kalendarza</li>
<li>Wreszcie - dodać metodę, która dodaje event do kalendarza</li>
</ul>

Idąc po kolei:

9. Skoro nasz serwis potrzebuje wiedziec o userze i książce - niech będą przekazywane do initializera serwisu:
```ruby
  def initialize(user, book)
    @user = user
    @book = book
  end
```
Ustalmy też, że event bedziemy dodawać zawsze w głównym kalendarzu user, dodajmy więc stałą  `CALENDAR_ID = 'primary'.freeze`

10. Dodajmy metodę, która będzie umiała skomunikować się z API Google calendar - stwórzmy tzw client-a `google_calendar_client`.
Samego klienta inicjalizujemy w ten sposób: `client = Google::Apis::CalendarV3::CalendarService.new`.

Na początku klasy musimy też załączyć odpowiednie biblioteki, żeby wszystko zadziałało:

```ruby
require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets'
```

11. Czyli w tym momencie nasza metoda wygląda:

```ruby
def google_calendar_client
  client = Google::Apis::CalendarV3::CalendarService.new
end
```

A jej wywołanie, w całości: `UserCalendarNotifier.new(user, book).google_calendar_client`

Ale to dopiero początek:) w ten spoób jedynie zainicjowaliśmy komunikację.
Potrzebujemy teraz się zautoryzować, rozszerzymy więc metodę naszego klienta o secrets-y, mozemy je wydzielić do osobnej metody:
```ruby
def secrets
    Google::APIClient::ClientSecrets.new({
      'web' => {
        'access_token' => user.token,
        'refresh_token' => user.refresh_token,
        'client_id' => A9n.google_client_id,
        'client_secret' => A9n.google_client_secret
      }
    })
  end
```
…a następnie użyć w naszej metodize budującej komunikację;
Zanim jednak to zrobimy - pamiętajmy o zabezpieczeniu się na wypadek błędów w komunikacji i zamknięciu w blok begin z rescue.
Tu link, jeśli potrzebujesz na szybko przyswoic temat obsługi wyjątków https://rollbar.com/guides/ruby/how-to-handle-exceptions-in-ruby/.

12. Finalna postać klienta:

```ruby
  def google_calendar_client(user)
    client = Google::Apis::CalendarV3::CalendarService.new

    begin
      client.authorization = secrets.to_authorization
      client.authorization.grant_type = 'refresh_token'
    rescue StandardError => e
      Rails.logger.debug e.message
    end

    client
  end
```
Ok! Na tym etapie mamy gotowego klienta do komunikacji!
Sprawdzmy sobie w konsoli: `UserCalendarNotifier.new(User.last, Book.last).google_calendar_client`

Możemy też sprawdzic, czy jesteśmy w stanie naszym klientem pobrać listę kalendarzy: 
`UserCalendarNotifier.new(User.last, Book.last).send(:google_calendar_client).get_calendar('primary')`
<strong>Uwaga</strong> - jeżeli dostajesz błąd unauthorized - upewnij się, że dla danego usera, na którym testujesz w konsoli masz aktywną sesję w przeglądarce (do komunikacji z API Google Calendar wykorzystujemy token, ktory mógł wygasnąć!)
```
Caught error Unauthorized
Error - #<Google::Apis::AuthorizationError: Unauthorized status_code: 401
```

13. Ok! Wiemy już ze potrafimy nawiązać połączenie z API kalendarza, dla naszego konkretnego usera;
Spróbujmy teraz dodać metodę która dodaje event w kalendarzu.

Musimy sobie przygotować dane opisujące ten event - wydzielmy to do osobnej metody, określając też “za dwa tygodnie”, również w osobnej metodzie
Protip: używamy memoizacji, żeby “now” nie zwrociło nam przy każdym wywołaniu innej daty i godziny:

```ruby
def event_data
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
  @two_week_from_now ||= Time.zone.now + 14.days
end
```
14. Wykorzystamy teraz te dane w metodzie, która wywołuje na kliencie dodanie eventu:

```ruby
def insert_event
  get_google_calendar_client.insert_event(CALENDAR_ID, event_data)
end
```

Warto zabezpieczyć się też na wypadek, gdybysz nasz user np. nie byl zintegrowany z Googlem (nie miał tokena/refresh tokena) - w takiej sytuacji - po prostu nie będziemy podejmowali komunikacji z Google:

```ruby
return unless user.token.present? && user.refresh_token.present?
```

W zasadzie to jedyna nasza publiczna metoda! Chcemy, żeby tylko z tego inserta mozna było skorzystac z zewnątrz, czyli chcemy, żeby można bylo wywołać:
`UserCalendarNotifier.new(user, book).insert_event`

To oznacza, ze wszystko inne, mozemy przenieść do metod prywatnych. Końcowa forma klasy:

```ruby
require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets'

class UserCalendarNotifier
  CALENDAR_ID = 'primary'.freeze

  def initialize(user, book)
    @user = user
    @book = book
  end

  def insert_event
    return unless user.token.present? && user.refresh_token.present?

    google_calendar_client.insert_event(CALENDAR_ID, event_data)
  end

  private

  attr_reader :user, :book

  def google_calendar_client
    client = Google::Apis::CalendarV3::CalendarService.new

    begin
      client.authorization = secrets.to_authorization
      client.authorization.grant_type = 'refresh_token'
    rescue StandardError => e
      Rails.logger.debug e.message
    end

    client
  end

  def secrets
    Google::APIClient::ClientSecrets.new({
      'web' => {
        'access_token' => user.token,
        'refresh_token' => user.refresh_token,
        'client_id' => A9n.google_client_id,
        'client_secret' => A9n.google_client_secret
      }
    })
  end

  def event_data
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
    @two_week_from_now ||= Time.zone.now + 14.days
  end
end
```

15. Tak stworzoną akcję należy teraz podpiąć w odpowiednim miejscu aplikacji, które odpowiada za wypożyczenie ksiązki. Bedzie to akcja `create` w kontrolerze `app/controllers/book_loans_controller.rb`.
16. Tworzymy w tym kontrolerze metodę odwołującą się do metody `insert_event` z naszego serwisu z klientem API:
```ruby
  def notice_calendar
    UserCalendarNotifier.new(current_user, book).insert_event
  end
```
i wywołujemy ją w metodzie `create` kontrolera odpowiadającego za wypożyczenie w sekcji, która kończy się sukcesem, wystarczy zatem, ze wywołamy tam `notice_calendar`.

17. Sprawdźmy teraz czy nasze zmiany zadziałały. 
Zalogujmy się do aplikacji kontem Google (ważne: konto musi być dodane jako testowe w panelu API dla developerów) a następnie kliknijmy na button "Loan" przy jednej z książek. 
W kalendarzu Google sprawdźmy czy w dacie za dwa tygodnie od dziś pojawiło się nowe wydarzenie. Jeśli tak to gratulacje, właśnie zakończyłeś/aś zadanie!
Po kliknieciu w ten button
<img src="../app/assets/images/docs/loan_click.png" />

W kalendarzu pojawi się nowe wydarzenie:
<img src="../app/assets/images/docs/cal_event.png" />

## Zadanie dodatkowe

1. Spróbuj zapisać w bazie id eventu tworzonego w kalendarzu i w momencie oddania książki usuń event z kalendarza.
