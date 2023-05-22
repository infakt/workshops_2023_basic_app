# Hotwire - dynamiczna usuwanie elementów z listy książek

## Tło

Jeśli ktoś w naszej aplikacji usunie książkę, to na liście, którą widzi drugi użytkownika zalogowany do aplikacji usuniętej książki nie powinno być.
Wszystko ma się odbyć bez potrzeby odświeżenia strony przez drugiego użytkownika.

## QUICK FIX
1. Aby nie mieć błędów w konsoli JavaScript (biblioteka popper) mały fix w pliku `app/javascript/application.js`, zastępujemy `import "popper";` wpisem :
```
import * as Popper from '@popperjs/core';
window.Popper = Popper;
```
2. Weryfikujemy fix logując się do aplikacji, uruchamiamy konsole JavaScript (przeglądarkowej) i patrzymy czy nie mamy żadnych błędów na czerwono.
3. Jeśli wszystko jest ok, to idziemy do instlacji potrzebnego gem'a.


## HOW TO
1. Dodajemy gem `hotwire-rails` (plik Gemfile).
2. Uruchamiamy `bundle` aby nowy gem został zainstalowany.
3. Następnie za pomocą polecenia `bundle exec rails hotwire:install` dodajemy wymagane elementy konfiguracyjne hotwire, będą pomocne w tym i kolejnych zadaniach.
4. Restartujemuy serwer aplikacji.
5. Aby mieć pewność, że nic na tym etapie nie przestało działać, wchodzimy do aplikacji i sprawdzamy czy ładuje się lista książek.
6. Potrzebujemy zrobić mały refactor, aby łatwiej nam było pracować w dalszej części więc dodajemy nowy plik (partial) `app/views/books/_index_item.html.erb`.
7. Do nowego partiala przenosimy z pliku: `app/views/books/index.html.erb` linie:
```
<div class="col-md-6">
  <div class="book">
  <h2 class="book-title"><%= book.title %></h2>
  <div class="book-details">by <%= book.author.full_name %></div>
  <div class="book-details">Published in <%= book.year %></div>
  <div class="book-category">Category: <%= book.category.name %></div>
    <div class="book-btns">
      <%= link_to 'Details', book_path(book), class: "btn book-btn btn-details" %>
      <%= reserve_book_button(book, css_class: 'book-btn btn-reserve') %>
      <%= loan_book_button(book, css_class: 'book-btn btn-reserve') %>
    </div>
  </div>
</div>
```
8. A w pliku, z którego te dane przenieśmy wklejamy odwołanie do partiala  `<%= render 'index_item', book: book %>`.
9. Czas na kolejny check, czy aplikacja działa poprawnie i wyświetla się lista z książkami.
10. Teraz zaczynamy przygotowania pod uruchomienie nowej funkcjonalności, więc w pliku `app/views/books/_index_item.html.erb` dodajemy ID `id="<%= dom_id book %>"` do pierwszego div'a:
```
<div class="col-md-6" id="<%= dom_id book %>">
```
11. Do modelu `app/models/book.rb` dodajemy: `after_destroy_commit -> { broadcast_remove_to :books }`, na przykład po walidacjach i przed deklaracją metod.
12. I wracamy do pliku `app/views/books/index.html.erb` dodając deklarację `<%= turbo_stream_from :books %>` (na początku pliku).
13. Czas na kolejny check, czy aplikacja działa poprawnie i wyświetla się lista z książkami.
14. Wszystko zamontowane, więc testujemy :) W jednej karcie uruchamiamy listę księżek w drugiej karcie przeglądarki wchodzimy na detal konkretnej książki.
15. Usuwamy książkę.
16. Wracamy do pierwszej karty i bez przeładowania powinniśmy zobaczyć zmiany, które wprowadziliśmy.

## Zadania dodatkowe dla chętnych:
1. Przetestuj działanie rozwiązania, używając konsoli railsowej (`bundle exec rails c`).
2. Poszukaj bardziej sprytnego rozwiązania do renderowania kolekcji, i zatąp nim to co mamy w `app/views/books/index.html.erb`:
```
<% @books.each do |book| %>
  <%= render 'index_item', book: book %>
<% end %>
```
