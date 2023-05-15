# Migracja typu danych kolumny `due_date` modelu `BookLoan`

Na potrzeby testów funkcjonalności, którą dzisiaj napiszemy, wygenerujemy migrację, która sprawi, że kolumna `due_date` zamiast być typem `date`, będzie miała typ `datetime`.

## HOW TO

1. Będąc w katalogu z repozytorium uruchom komendę `rails g migration ChangeBookLoanDueDateToDateTime`.
2. Po wygenerowaniu pustego pliku migracyjnego powyższym poleceniem, otwieramy go w edytorze. Znajdziesz go w katalogu `db/migrate` pod nazwą podobną do `db/migrate/20230419000129_change_book_loan_due_date_to_date_time.rb`.
3. Uzupełnij ciało metody `change` - powinna wyglądać tak:
```
def change
  change_column :book_loans, :due_date, :datetime
end
```
4. Zapisz plik i wróć do terminala.
5. Wywołaj polecenie `rails db:migrate`. W terminalu powinieneś uzyskać informację o tym, co zmieniło się w bazie danych (najlepiej to, co chcemy 😉).
6. Gotowe! Możesz zabierać się za dzisiejsze zadanie!
