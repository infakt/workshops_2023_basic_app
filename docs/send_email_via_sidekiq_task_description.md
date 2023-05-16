# Zadania w tle - wysyłanie wiadomości email z użyciem Sidekiq
## Cel zadania

Po wypożyczeniu książki, chcemy w tle wysyłać użytkownikowi email informujący o udanym wypożyczeniu i założonej z góry dacie oddania książki. W tym celu potrzebować będziemy gema `Sidekiq` do przetwarzania zadań w tle. Oprócz tego stworzymy klasę mailera oraz templatkę wiadomości.

## Zaczynamy!

W katalogu `app/mailers` stwórz klasę `UserMailer` dziedziczącą po `ApplicationMailer`. Zdefiniuj w niej metodę, np. `loan_created_email`, która będzie odpowiadać za wysłanie maila. Metoda powinna przyjmować jako argument obiekt klasy `BookLoan`, zapisywać do zmiennych instancyjnych tytuł i datę terminu wypożyczenia książki oraz wywoływać metodę [mail](https://api.rubyonrails.org/v7.0.4.2/classes/ActionMailer/Base.html#method-i-mail) w celu stworzenia wiadomości i werenderowania templatki.

## Gdzie ta templatka?

Nigdzie. 😎
Stwórz katalog `app/views/user_mailer` i w pliku nazwanym tak, jak Twoja metoda w mailerze (`loan_created_email.html.erb`) napisz wymyśloną przez Ciebie treść maila, wykorzystując wartości zapisane wcześniej do zmiennych w taki sposób, aby wyrenderowana później wiadomość zawierała tytuł książki oraz informację o tym, do kiedy należy ją zwrócić.

## Tworzymy Job

Dodaj do aplikacji gem `Sidekiq`, np. wywołując w katalogu projektu polecenie `bundle add sidekiq`.

Stwórz katalog `app/jobs`, a w nim klasę z przyrostkiem `Job` na końcu. Zgodnie z konwencją, powinna nazywać się podobnie jak Twoja metoda mailera oraz plik z treścią wiadomości email, np. `LoanCreatedJob`(`loan_created_job.rb`). Dodaj do niej `include` jak poniżej:
```
class SomeJob
  include Sidekiq::Job

  def perform; end
end
```
Klasa powinna zawierać metodę `perform`, w której należy wywołać metodę mailera (nie musisz tworzyć obiektu mailera, metody mailera są statyczne).

Metoda mailera zwróci nam obiekt wiadomości. Dlatego, żeby ją wysłać, musimy wywołać bezpośrednio na nim jeszcze jedną metodę, np. `deliver_now` lub `deliver_later`.

Przykładowa definicja metody `perform`:
```
def perform(id)
  book_loan = BookLoan.find(id)

  UserMailer.loan_created_email(book_loan).deliver_now
end
```

## Co dalej?

Mamy już wszystko gotowe, żeby wysłać prostego maila. Teraz należy wywołać `Job`a w odpowiednim miejscu. Kiedy chcemy wysyłać wiadomość? Po udanym przebiegu wypożyczenia - czyli w `BookLoansController#create`, w gałęzi `if`a odpowiadającej za prawidłowy zapis obiektu wypożyczenia.

Nad `format.html(...)` umieszczamy wywołanie, np. `LoanCreatedJob.perform_async(@book_loan.id)` (metoda w `Job`ie ma się nazywać `perform`, to nie pomyłka 🙂).

## Testujemy!
Wypożycz książkę przez aplikację webową. Jeżeli wszystko wykonałeś poprawnie, w nowej karcie powinna otworzyć się Twoja wiadomość (to dzięki gemowi `letter_opener`!). 👏
