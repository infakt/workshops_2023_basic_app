# Zadania w tle - wysyłanie wiadomości email z użyciem Sidekiq cd.
## Cel zadania

Dodajemy analogiczny email, to znaczy:
- templatkę
- job
- nową metodę w klasie `UserMailer`

Ta wiadomość ma informować użytkownika o tym, że termin oddania książki mija jutro. Potrzebne parametry będą więc takie same jak w poprzedniej wiadomości, różnić się będzie jedynie treść.

Wiadomość wyślemy na dwa sposoby.

Przykładowa nazwa `Job`a / metody - `DueDateNotificationJob` / `due_date_notification_email`.

## Zakolejkowanie Joba z opóźnieniem

Przygotowaną wiadomość wyślemy, zgodnie z założeniem, dzień przed terminem zwrotu książki. Możemy zrobić to, wywołując w `BookLoansController`(tak jak wcześniej) `Job`a, natomiast tym razem, zamiast metody `perform` użyjemy `perform_at`.

Jako parametr do metody `perform_at` należy podać jakiś interwał, np. obiekt klasy `Time` lub `DateTime`. W naszym wypadku może być to atrybut `due_date` obiektu wypożyczenia. Jednakże, przypomnienie ma być wysłane na dzień przed terminem zwrotu. Powinniśmy do `perform_at` podać odpowiednio "obrobioną" wartość.

W ten sposób kolejkujemy zadanie wysyłające wiadomość na określony, pożądany przez nas dzień.

Na potrzeby testu możesz otworzyć konsolę `rails c` i ręcznie wywołać `Job`:
```
DueDateNotificationJob.perform_in(10.seconds, BookLoan.last.id)
```

Pamiętaj u uruchomieniu Sidekiqa!

## Jak można zrobić to lepiej (i dlaczego)?

Nawiązując do prezentacji - kolejkowanie zadań ma nam upraszczać życie i odciążać aplikację - wykonywać zadania nie wymagające priorytetu w adekwatnej chwili i ponawiać je w razie niedostępności partnera, problemów z wysyłką maila lub innych możliwych błędów.

Kolejkowanie na dłuuugo do przodu nie jest dobrym pomysłem - chociażby dlatego, że z kolejką też może się "coś" stać.
Lepszym rozwiązaniem jest cykliczne wykonywanie zadań, których wywołania możemy się spodziewać. To znaczy - nie oczekujemy, że wywołają się w związku z inną akcją. Wiemy, że i tak powinny się wykonać, że, tak jak w naszym wypadku, codziennie komuś będzie kończył się termin wypożyczenia. Dlatego niewarto "zapychać" kolejki - lepiej regularnie weryfikować wypożyczenia i wtedy kolejkować powiadomienia (tutaj wiadomości email) krótkoterminowo.

## Do dzieła!

Zacznijmy od zmodyfikowania naszego `Job`a. Od teraz nie będzie on służył do wysyłki powiadomienia dla konkretnego obiektu wypożyczenia. Chcemy, żeby metoda `perform` iterowała (`BookLoan.where(...)`) po wszystkich aktywnych wypożyczeniach (`status: 'checked_out'`), które kończą się jutro (`due_date: Date.tomorrow`).

Na znalezionym zbiorze użyj pętli `each`, a w niej wywołaj metodę mailera jako parametr podając aktualny element zbioru.

Uwaga: Od teraz metoda `perform` w `Job`ie nie powinna przyjmować żadnego argumentu. Będzie działała inaczej, więc usuń jej wywołanie z kontrolera `BookLoansController`.

## Dodajemy gem sidekiq-cron i konfigurację

Dodajemy gem poleceniem `bundle add sidekiq-cron`. Jest to add-on pozwalający używać crona w Sidekiqu.

Stwórz plik `schedule.yml` w katalogu `config`. W tym pliku, zachowując strukturę yamlową (podobnie jak np. przy dodawaniu konfiguracji z kluczem API w zadaniach z zeszłego tygodnia), deklarujemy joby do wykonania:

```
your_job_name:
  cron: '0 8 * * *' # codziennie o 8 rano sprawdzamy, komu jutro kończy się termin i wysyłamy maila wszystkim znalezionym
  class: 'YourJobNameJob'
```

[Online-owy crono-pomocnik](https://crontab.guru/)

Po zapisaniu pliku zrestartuj Sidekiqa. Po ponownym uruchomieniu zauważysz, że Sidekiq widzi zadeklarowany do wykonania Job:
```
INFO: Cron Jobs - added job with name: due_date_notification
```

## Jak to przetestować?!?

Na potrzeby testów trochę "ponaciągamy" ramy czasowe. Żeby to zrobić, konieczna jest migracja typu danych (potrzebujemy MINUT). Instrukcja [tutaj](https://github.com/infakt/workshops_2023_basic_app/blob/main/docs/book_loan_duedate_datatype_migration.md):
1. W pliku `schedule.yml` ustaw crona na wykonywanie się co 3 minuty - '*/3 * * * *'.
2. W metodzie `prepare_book_loan` kontrolera `BookLoansController` zmień ustawianą wartość atrybutu `due_date` "na za kilka minut", np. `due_date: Time.zone.today + 5.minutes)`.
3. Wewnątrz Twojego `Job`a zmień w zapytaniu `where`(przed pętlą) ramy czasowe, o które odpytujemy bazę, np. `due_date: Time.zone.now..Time.zone.now + 4.minutes`.
4. Zrestartuj aplikację i Sidekiqa.
5. Wypożycz książkę. Po kilku minutach powinieneś otrzymać maila z przypomnieniem o zwrocie książki! Status kolejkowanych i wykonywanych zadań możesz śledzić w logach Sidekiqa. Jeżeli nie widzisz tam swojego `Job`a - coś jest nie tak. Jeżeli mail przyszedł - gratulacje! To koniec pierwszej części dzisiejszych warsztatów! :)
