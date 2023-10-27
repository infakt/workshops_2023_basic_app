# Pierwsze uruchomienie Capybary

## Po co to wszystko?

Capybara jest jednym z narzędzi do testowania interfejsu użytkownika w aplikacjach opartych na Ruby on Rails. Capybara umożliwia pisanie testów, które symulują interakcje użytkownika z aplikacją, takie jak kliknięcia, wypełnianie formularzy czy nawigację po stronach. Dzięki Capybarze można testować zachowanie aplikacji na różnych poziomach, od prostych testów jednostkowych po bardziej zaawansowane testy integracyjne.

Tutaj koniec teorii, więcej na prezentacji.

## Potrzebne gemy:

Gemy warto umieścić w grupie ```:test``` lub ```:development``` (powinny być juz dodane, ale upewnijmy się)

```ruby
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
```
Po dodaniu do gemfila odpalamy ```bundle install```

## Dodanie potrzebnych bibliotek

Aby móc korzystać z funkcji capybary musimy je dodać do pliku ```rails_helper.rb``` lub ```spec_helper.rb``` w zależności od tego którego używamy w plikach testowych.

W wyżej wymienionym pliku dodajemy ```require 'capybara/rspec'``` (najlepiej przy innych ```require``` na samym dole)

Jeżeli korzystamy z innej biblioteki testowej (innej niz rspec) dodany pakiet będzie inny, wszystkie dostępne opcje znajdują się tutaj: https://github.com/teamcapybara/capybara

## Integracja z przeglądarką:
Bez dodania poniższych rzeczy testy capybary będą działały, jednak nie będziemy mieli możliwości podglądu co aktualnie się wykonuje.
Jeżeli nie masz chrome na swoim komputerze, to go pobierz, będzie znacznie szybciej. :D

1. Tworzymy plik spec/support/chromedriver.rb

```ruby
require 'selenium/webdriver'

Capybara.app_host = 'http://localhost:3010' # wybieramy port na którym capybara będzie uruchamiała przeglądarkę
Capybara.server_host = 'localhost'
Capybara.server_port = '3010' # wybieramy port

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.configure do |config|
  config.javascript_driver = :chrome
  config.default_driver = :chrome
end

```

2. Dodajemy plik do naszego helpera:

```require 'support/chromedriver'```

## Pora na pierwszy test!

Jedną z funkcjonalności idealnych pod testy z użyciem Capybary będzie test poprawnego logowania, zatem do dzieła!

1. Dodajemy nowy katalog /spec/features

2. W utworzonym katalogu dodajemy plik ```log_in_spec.rb```
Listę podstawowych akcji znajdziecie tutaj: https://gist.github.com/alexbrinkman/cc4bc502b06bf08bd079

Przykładowy test logowania (próba logowania nieprawidłowymi danymi)

```ruby
require 'rails_helper'

describe 'Log in', type: :feature do
  let(:user) { create(:user) }

  before do
    visit new_user_session_path
  end

  context 'when user is not registered' do
    let(:email) { 'not_existing@email.com' }
    let(:password) { 'password' }

    it 'displays error message' do # wszystkie capybarowe akcje wykonujemy w bloku it
      within '#new_user' do
        fill_in 'user_email',	with: email
        fill_in 'user_password',	with: password
        click_button 'Log in'
      end

      expect(page).to have_content('Invalid Email or password.')
    end
  end
end
```

3. Z racji tego, że akcje wykonujemy w bloku it, aby uspokoić rubocopa dodajemy do pliku ```.rubocop.yml```
```yml
RSpec/ExampleLength:
  Exclude:
    - 'spec/features/**/*'

RSpec/AnyInstance:
  Enabled: false
```

4. Test odpalamy standardową komendą testową: ```rspec spec/features/log_in_spec.rb```

## Pierwsze wyzwania

W przypadku osób, które zrealizowały zadanie związane z danymi pogodowymi mogą natrafić na pewne wyzwanie. Test może nie przejść.
Aby temu zapobiec potrzebujemy zamockować dane zwracające przez WeatherApi. Nie jest dobrą praktyką wysyłanie requestów do naszego partnera przy każdym wykonywaniu testów.

```ruby
(...)
let(:weather_data) do
    {
      'location' => {
        'name' => 'Cracow'
      },
      'current' => {
        'condition' => {
          'text' => 'Sunny',
          'icon' => 'https://cdn.weatherapi.com/weather/64x64/day/113.png'
        },
        'temp_c' => 16
      }
    }
  end

  before do
    allow_any_instance_of(WeatherApiConnector).to receive(:weather_data).and_return(weather_data) # mockujemy dane pogodowe
    visit new_user_session_path # przed każdym testem odwiedzamy stronę logowania
  end
  (...)
```

## Zadanie!
1. W tym samym dopisz test poprawnego logowania
```ruby
context 'when user is registered' do
    ## Miejsce na Twój kodzik

    it 'logs in' do
      ### Miejsce na Twój kodzik

      expect(page).to have_content('Signed in successfully.')
    end
end
```

2. Dopisz test wypożyczenia książki
w katalogu ```spes/features``` utrórz plik ```loan_book_spec.rb```
test możemy zacząć od zalogowania do wypożyczenia książki (end to end) lub zacząć test juz jako zalogowany user.
Jak to zrobić znajdziemy tutaj [stubowanie sesji usera](https://sajadtorkamani.com/login-devise-user-in-capybara-tests/)
Pamiętaj o utworzeniu obiektu książki w bazie danych.
Korzystaj w opisanych akcji.
Powodzenia!
