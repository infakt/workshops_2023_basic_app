# Zadania w tle - wysyłanie wiadomości email z użyciem Sidekiq
## Cel zadania

Po wypożyczeniu książki, chcemy w tle wysyłać użytkownikowi email informujący o udanym wypożyczeniu i założonej z góry dacie oddania książki. W tym celu potrzebować będziemy gema `Sidekiq` do przetwarzania zadań w tle. Oprócz tego stworzymy klasę mailera oraz templatkę(szablon) wiadomości.

## Zaczynamy!

W katalogu `app/mailers` stwórz klasę `UserMailer` dziedziczącą(`<`) po `ApplicationMailer`. Zdefiniuj w niej metodę, np. `loan_created_email`, która będzie odpowiadać za wysłanie maila. Metoda powinna przyjmować jako argument obiekt klasy `BookLoan`, zapisywać do zmiennych instancyjnych(`@`) tytuł i datę terminu wypożyczenia książki oraz wywoływać metodę [mail](https://api.rubyonrails.org/v7.0.4.2/classes/ActionMailer/Base.html#method-i-mail) w celu stworzenia wiadomości i werenderowania templatki.

Zmiennych instancyjnych potrzebujemy, żeby móc wykorzystać je później w szablonie wiadomości. Tytuł książki możesz wydobyć z pomocą asocjacji(bazodanowego powiązania) obiektu wypożyczenia i książki: `book_loan.book.title`, a parametry, których chcemy użyć w metodzie `mail` to `(to: email_address, subject: email_subject)`, gdzie `email_address` to adres email użytkownika(atrybut `email`), którego również możesz "wyciągnąć" z obiektu klasy `BookLoan`, a `email_subject` to wymyślony przez Ciebie temat wiadomości podany jako `String`.

## Gdzie ta templatka?

Nigdzie. 😎

Stwórz katalog `app/views/user_mailer` i w pliku nazwanym tak, jak Twoja metoda w mailerze (`loan_created_email.html.erb`) napisz wymyśloną przez Ciebie treść maila, wykorzystując wartości zapisane wcześniej do zmiennych w taki sposób, aby wyrenderowana później wiadomość zawierała tytuł książki oraz informację o tym, do kiedy należy ją zwrócić. Z racji, że jest to ten sam typ pliku, co widoki w aplikacji, możesz korzystać z ERB-a (embedded Ruby), czyli znaczników zawierających kod Ruby, w naszym przypadku np. <%= @title %>.

Po uzupełnieniu szablonu uruchom konsolę `rails c`(lub `bundle exec rails c`) i spróbuj "ręcznie" wysłać tego maila.

```
book_loan = BookLoan.last
UserMailer.loan_created_email(book_loan).deliver_now
```

Jeżeli wiadomość zostaje wysłana - możesz śmiało iść dalej.

## Tworzymy Job

Dodaj do aplikacji gem [Sidekiq](https://github.com/sidekiq/sidekiq), np. wywołując w katalogu projektu polecenie `bundle add sidekiq`.

Zobacz czy Sidekiq "wstaje" - uruchom go poleceniem `sidekiq`(lub `bundle exec sidekiq`) w osobnym terminalu. Pamiętaj o uruchomionym Redisie!

W katalogu `app/jobs` stwórz klasę z końcówką `Job`. Zgodnie z konwencją, powinna nazywać się podobnie jak Twoja metoda mailera oraz plik z treścią wiadomości email, np. `LoanCreatedJob`(`loan_created_job.rb`). Dodaj do niej `include` jak poniżej:
```
class SomeJob
  include Sidekiq::Job

  def perform; end
end
```

Załączamy w ten sposób funkcjonalności zaimplementowane w `gem`ie Sidekiq do stworzonej przez nas klasy.

Klasa powinna zawierać metodę `perform`, do której podajemy jako argument `id` obiektu wypożyczenia, żeby potem przy jego pomocy odnaleźć obiekt, przypisać w metodzie do zmiennej i wykorzystać.

Wewnątrz metody `perform` należy wywołać metodę mailera (nie musisz tworzyć obiektu mailera, metody mailera są [statyczne](https://pl.wikipedia.org/wiki/Metoda_statyczna)).
Metoda mailera zwróci nam obiekt wiadomości. Dlatego, żeby ją wysłać, musimy wywołać bezpośrednio na nim jeszcze jedną metodę, np. `deliver_now`.

Przykładowa definicja metody `perform`:
```
def perform(book_loan_id)
  book_loan = BookLoan.find(book_loan_id)

  UserMailer.loan_created_email(book_loan).deliver_now
end
```

## Czas w aplikacji

Dla dokładnego zwracania godziny w aplikacji (z właściwej strefy czasowej) warto dodać w pliku `config/application.rb` linię
```
config.time_zone = 'Warsaw'
```
np. w wierszu 13.

## Co dalej?

Mamy już wszystko gotowe, żeby wysłać prostego maila. Teraz należy wywołać `Job`a w odpowiednim miejscu. Kiedy chcemy wysyłać wiadomość? Po udanym przebiegu wypożyczenia - czyli w `BookLoansController#create`, w gałęzi `if`a odpowiadającej za prawidłowy zapis obiektu wypożyczenia.

Nad `format.html(...)` umieszczamy wywołanie, np. `LoanCreatedJob.perform_async(@book_loan.id)` (metoda w `Job`ie ma się nazywać `perform`, to nie pomyłka 🙂). `perform_async` to metoda Sidekiqa, której wykonanie zapewnia nas, że `Job` zostanie zakolejkowany i wykonany asynchronicznie, czyli bez naszego oczekiwania i w dogodnym dla aplikacji momencie - W TLE.

## Testujemy!

Wypożycz książkę przez aplikację webową. Jeżeli wszystko wykonałeś poprawnie, w nowej karcie powinna otworzyć się Twoja wiadomość (to dzięki gemowi `letter_opener`!). 👏

## Mail nie otwiera się w przeglądarce - a błędów nie widać?

Sprawdź, czy mail utworzył się w katalogu `tmp/letter_opener` (w katalogu projektu). Jeżeli tak - zadanie jest wykonane poprawnie. Jeśli chcesz dla pewności spróbować podpiąć podgląd webowy maili z `letter_opener`a - instrukcja znajduje się w pliku `letter_opener_web.md`.
