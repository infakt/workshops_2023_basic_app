# Umożliwienie tzw 'inline edition' dla książek (na przykładzie ilości stron)

## Cel zadania

Chcemy, żeby bez przeładowania strony użytkownik mógł zmienić ilość stron w książce, na jej podglądzie.
UWAGA! zadanie zakłada przejście [poprzedniego](https://github.com/infakt/workshops_2023_basic_app/pull/31/files?short_path=2a48237#diff-2a48237ae080365745b1b88d04dc12673515ba2cb16377dcd13df82d795033a5)
A przynajmniej:
* dodanie gema 'hotwire-rails'
* instalację
* poprawkę zw. z Popperem

## Etapy zadania

1. Przeładowanie fragmentu "ilości stron", za pomocą linku i turbo-frame
2. Zapis/cancel wartości z inline edition
3. Schowanie zbędnych przycisków na pełnym formularzu


## Działamy!

## Etap 1 - Przeładowanie fragmentu "ilości stron", a pomocą linku i turbo-frame

1. Nauczmy się najpierw przeładowywać tylko fragment strony
2. Na widoku `app/views/books/show.html.erb` zamykamy div-a w którym wyświetlona jest ilośc stron w ramkę turbo (`turbo-frame`); musimy nadać jej odpowiednią, unikalną nazwę, żebyśmy mogli się do niej odwoływać z innych widoków.
Żeby nazwa była unikalna, dla kazdej książki dodajemy jej id do nazwy ramki - `dom_id(@book, 'page_count')`

```ruby
<%= turbo_frame_tag dom_id(@book, 'page_count') do %>
  <div class="book-info mb-4">
    <div class="book-info-label">Pages:</div>
    #...
<% end %>
```

3. Sprawdźmy jak to wygląda teraz na widoku książki. Sprawdzając HTML wokół ilości stron, powinniśmy zobaczyć:
```html
<turbo-frame id="page_count_book_1">
```
Gdzie 1 to ID książki, którą przeglądamy

4. OK, dodajmy teraz link do "przeładowania". 
To przeładowanie - jest tak po części... 'przejściem do edycji', więc dodajmy na podglądzie książki, zraz obok ilośc stron po prostu link
```ruby
<%= link_to 'edit', edit_book_path(@book)%>
```

5. Sprawdzamy co teraz! Wejdz w podgląd książki i kliknij...
...i uuu... w miejscu Page: XXX - CONTENT MISSING!
W konsoli JS:
```
Uncaught (in promise) Error: The response (200) did not contain the expected <turbo-frame id="page_count_book_1"> and will be ignored. To perform a full page visit instead, set turbo-visit-control to reload.
```
 
Dlaczego? Co nam to mówi?
Dlatego, ze linkujemy z frame'a, który puka do kontrolera z edycją, ale **na widoku edycji nie ma odpowiadającego mu frame'a**!
Więc nie umie tego na nic 'zamienić'

6. Musimy tym samym frame'em  (tą damą jego nazwą) objąć to, co chcemy przeładować, czyli na widoku `app/views/books/_form.html.erb` - fragment z ilością stron:
```ruby
<%= turbo_frame_tag dom_id(book, 'page_count') do %>
  <div class="form-group">
    <%= form.label :page_count %>
    <%= form.number_field :page_count, class: 'form-control' %>
  </div>
<% end %>
```
**Zwróćcie uwagę jak budujemy tutaj nazwę ramki - musi być taka sama jak na podglądzie książki!**

7. Sprawdzamy teraz jak to działa. Wejdź w podgląd książki i kliknij edit...
**Brawo! Powinna ilość stron przeładować się element edycji**

## Etap 2 - Zapis/cancel wartości z inline edition

1. Niby fajnie, ale naszego "formularza" inline'owego... nie da się zapisać :D
Dzieje się tak dlatego, z dwóch powodów:
a) przeładowujemy tylko malutki fragment - nie mamy formularza wokół
b) brakuje nam przycisku do zapisu / cancel

Pamiętajmy, ważną zasadę. Jeżeli coś (np link) jest wewnątrz frame-a - jego docelowy widok będzie próbował przeładować dokładnie tego frame'a, o takiej samej nazwie.
Zacznijmy więc od CANCEL

2. CANCEL

CANCEL chcemy mieć tam, gdzie jest pole edycji, więc musimy dodać je w `app/views/books/_form.html.erb`
```ruby
<%= turbo_frame_tag dom_id(book, 'page_count') do %>
  <div class="form-group">
    <%= form.label :page_count %>
    <%= form.number_field :page_count, class: 'form-control' %>
    <%= link_to 'Cancel', book_path(book) %>
  </div>
<% end %>
```
Odśwież widok książki, kliknij edit i sprawdź czy działa cancel. Powinien!
__Zastanówmy się chwilę dlaczego zadziałało ;)__
Jesteśmy we frame'ie page_count_book_X.
Klik w cancel, powoduje przeładowanie "do widoku książki", ale przeładowuje tylko ten frame!
Czyli przeładowanie frame'a page_count_book_X - renderuje ten mały fragmencik z `show.html.erb`

**UWAGA**
Ten sam formularz używamy na widoku edycji i dodawania książki.
...jeżeli teraz wejdziecie w dodawnie książki, to widok się nie załaduje - booo `book_path(book)` potrzebuje ID, a przy dodwaniu nowej ksiazki jeszcze do nie ma
Zabezpieczmy to przy pomocy warunku:
```ruby
<%= link_to 'Cancel', book_path(book) if book.persisted? %>
```

3. SAVE


...Z tym nie będzie juz tak łatwo. Dlaczego? Bo jak w tym naszym trybie inline edition sprawdzimy HTML-a, to owszem - mamy input field. Ale nie mamy formularza wokół!
A formularz jest potrzebny, żeby móc wysłać dane do kontrolera.
Obudujmy więc odpowiednio nasz widok, w `show.html.erb`:
```ruby
<%= form_with(model: @book, data: { turbo_frame: dom_id(@book, 'page_count') }) do |form| %>
  <%= turbo_frame_tag dom_id(@book, 'page_count') do %>
  #...
  <% end %>
<% end %>
```
Kluczowe, jest określenie atrybutów formularza - `data: { turbo_frame: dom_id(@book, 'page_count') }`

4. Dodajmy teraz przycisk zapisu
Znowu, tak jak cancel - musi być koło inputa, więc na widoku `app/views/books/_form.html.erb`:
```ruby
<%= turbo_frame_tag dom_id(book, 'page_count') do %>
  <div class="form-group">
    <%= form.label :page_count %>
    <%= form.number_field :page_count, class: 'form-control' %>
    <%= link_to 'Cancel', book_path(book) if book.persisted? %>
    <%= form.button 'Save' %>
  </div>
<% end %>
```

5. TESTUJEMY! Powinno działać! :)

## Etap 3 - Schowanie zbędnych przycisków na pełnym formularzu

I wydawaloby się, że możemy obtrąbić sukces, ale... nie do końca.

Jeżeli wejdziemy w widok pełnej edycji, albo dodawania książki - to mamy tam przyciski do zapisu i cancel, nagle w połowie, przy naszych 'pages`
Musicie przyznac, że to bez sensu;)

Ten problem ogramy już CSSem!

1. Dodajmy klasy które schowają/pokaza przyciski
W pliku `main.scss` dodajmy:
```scss

.inline-action {
  display: none;
}
.inline-show .inline-action {
  display: initial;
}
```
pierwsza klasa - schowa przyciski, druga - pokaże je, jeżeli na stronie jest klasa `inline-show`

2. Dodajmy te klasy do naszych przycisków - cancel i save
W `app/views/books/_form.html.erb`:
```ruby
  <%= link_to 'Cancel', book_path(book), class: 'inline-action' if book.persisted? %>
  <%= form.button 'Save', class: 'inline-action' %>
```

3. Schowaliśmy je... ale teraz "wszędzie" :) Więc musimy je pokazać dla naszego inline edition
W tym celu dodamy klasę `inline-show` do naszego frame'a, na widoku `app/views/books/show.html.erb`:
```ruby
<%= turbo_frame_tag dom_id(@book, 'page_count'), class: 'inline-show' do %>
#...
```

**TADAM!!!**

Fascynatom, polecam poczytać o frame'ach [tutaj](https://turbo.hotwired.dev/handbook/frames)
