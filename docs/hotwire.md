# Hotwire

## I. Dynamiczne usuwanie elementów z listy (broadcasting)

Jeśli ktoś w naszej aplikacji usunie książkę, to na liście, którą widzi drugi użytkownik zalogowany do aplikacji usuniętej książki nie powinno być.
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
3. Następnie za pomocą polecenia `bundle exec rails hotwire:install` dodajemy wymagane elementy konfiguracyjne hotwire, będą pomocne w tym i kolejnych zadaniach. Jeśli zobaczycie czerwone alerty w konsoli - nie przejmujcie się. Wynikają z tego, że część komponentów już w projekcie jest zainstalowane i dlatego instalator je pominął:
```
Import Stimulus controllers
File unchanged! The supplied flag value not found!  app/javascript/application.js
#...
Import Turbo
File unchanged! The supplied flag value not found!  app/javascript/application.js
#...
```

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
8. A w pliku, z którego te dane przenieśmy dodajemy odwołanie do partiala  `<%= render 'index_item', book: book %>`.
9. Czas na kolejny check, czy aplikacja działa poprawnie i wyświetla się lista z książkami.
10. Teraz zaczynamy przygotowania pod uruchomienie nowej funkcjonalności, więc w pliku `app/views/books/_index_item.html.erb` dodajemy ID `id="<%= dom_id book %>"` do pierwszego div'a:
```
<div class="col-md-6" id="<%= dom_id book %>">
```

11. Do modelu `app/models/book.rb` dodajemy: `after_destroy_commit -> { broadcast_remove_to :books }`, na przykład po walidacjach i przed deklaracją metod.
12. Restartujemy server.
13. I wracamy do pliku `app/views/books/index.html.erb` dodając deklarację `<%= turbo_stream_from :books %>` (na początku pliku).
14. Czas na kolejny check, czy aplikacja działa poprawnie i wyświetla się lista z książkami.
15. Wszystko zamontowane, więc testujemy :) W jednej karcie uruchamiamy listę książek, w drugiej karcie przeglądarki wchodzimy na detal konkretnej książki.
16. Usuwamy książkę.
17. Wracamy do pierwszej karty i bez przeładowania powinniśmy zobaczyć zmiany, które wprowadziliśmy.

## Zadania dodatkowe dla chętnych:
1. Przetestuj działanie rozwiązania, używając konsoli railsowej (`bundle exec rails c`).
2. Poszukaj bardziej sprytnego rozwiązania do renderowania kolekcji, i zatąp nim to co mamy w `app/views/books/index.html.erb`:
```
<% @books.each do |book| %>
  <%= render 'index_item', book: book %>
<% end %>
```



------------------------------------------------------------------------------------
## II. Dynamiczne doładowywanie zawartości strony (kaminari + turbo frame)

Jak nasza biblioteka się rozrośnie, to aby nie ładować na stronie `Books` wszystkich rekordów wdrożymy paginację, użyjemy do tego gema [kaminari](https://github.com/kaminari/kaminari)
A następnie zmienimy paginację, w doczytywaną automatycznie listę.


## HOW TO
1. Dodajemy gem `kaminari` (plik Gemfile).
2. Uruchamiamy `bundle` aby nowy gem został zainstalowany.
3. Następnie za pomocą polecenia `bundle exec rails g kaminari:config` dodajemy wymagane elementy konfiguracyjne.
4. Restartujemuy serwer aplikacji.
5. Dodajemy kilka książek tak aby było wszystkich więcej niż 25, warto użyć narzędzia `Faker`, używaliśmy go w seedach.
6. W kontrolerze `app/controllers/books_controller.rb` zmieniamy wywołanie `Book.all` na `Book.page(params[:page])`
7. Aby mieć pewność, że nic na tym etapie nie przestało działać, wchodzimy do aplikacji i sprawdzamy czy ładuje się lista książek, ale widzimy tylko 25 rekordów - to dobrze, tak powinno być na tym etapie.
8. Dodajemy na widoku `app/views/books/index.html.erb` wpis `<div class="row"><%= paginate @books %></div>` wpis umieszczamy po zakończneiu each'a pod elementem `<% end %>`.
8. Czas na kolejny check, czy aplikacja działa poprawnie i wyświetla się lista z książkami wraz z linkami do kolejnych stron.
9. W tym momencie mamy wdrożoną paginację w naszej aplikacji na liście książek, brawo!
10. Na widoku `app/views/books/index.html.erb` usuwamy dodaną przed chwilą paginacje - nie będzie nam już potrzebna (`<div class="row"><%= paginate @books %></div>`)
11. Aby było łatwiej wprowadzać kolejne zmiany, zmieńmy sposób renderowania elementów z użycia pętli na coś co nam Railsy podrzucają `<%= render partial: 'index_item', collection: @books, as: :book %>` (to było zadanie dodatkowe we wcześniejszym temacie, jeśli to masz zrobione zapraszam dalej).
12. Kolejny check - sprawdzamy czy aplikacja działa poprawnie i wyświetla się lista z książkami tym razem bez linków do kolejnych stron.
13. Powyżej div'a `<div class="row">` dodajemy turbo_frame_tag `<%= turbo_frame_tag "paginate_page_#{@books.current_page}" do %>` i kończymy `<% end %>` po zamknięciu div'a:
```
<%= turbo_frame_tag "paginate_page_#{@books.current_page}" do %>
  <div class="row">
    <%= render partial: 'index_item', collection: @books, as: :book %>
  </div>
<% end %>
```

14. Sprawdzamy jak strona wygląda i działa, czy nam czegoś nie brakuje? Tak, nic się nie dzieje jak zjedziemy na dół strony, naprawmy to :)
15. Przed zamkniąciem metody turbo_frame_tag, po renderowaniui partiala dodajemy taki oto wpis:
```
<% if @books.next_page %>
  <%= turbo_frame_tag "paginate_page_#{@books.next_page}", src: books_path(page: @books.next_page), loading: 'lazy' do %>
    Loading...
  <% end %>
<% end %>
```

16. Cały widok index wygląda następująco:
```
<%= turbo_stream_from :books %>

<div class="container">
  <h1 class="text-center mb-5">Books</h1>
  <%= turbo_frame_tag "paginate_page_#{@books.current_page}" do %>
    <div class="row">
      <%= render partial: 'index_item', collection: @books, as: :book %>
    </div>
    <% if @books.next_page %>
      <%= turbo_frame_tag "paginate_page_#{@books.next_page}", src: books_path(page: @books.next_page), loading: 'lazy' do %>
        Loading...
      <% end %>
    <% end %>
  <% end %>
</div>
```

17. Sprawdźmy czy wszystko działa teraz jak należy?
18. Wszystko powyżej działa w taki sposób, że po zejściu na dół strony, pojawia się na moment `loading...` a następnie turbo pobiera z adresu ktory przekazaliśmy jako `src` nowe dane i umieszcza je na stronie. Robi to aż do momentu jak występuje kolejny numer strony (if dotyczący next_page).
19. Mamy to! Strona działa jak zaplanowaliśmy, ale czy na pewno? Sprawdźmy czy można wejść na detal.
20. Aby naprawić działanie linków musimy dodać deklaracje `data: { turbo: false }` do metod link_to, button_to.
21. Teraz wszystko działa, brawo!


## Zadanie dodatkowe dla chętnych:
1. Jak możemy zrobić, aby na stronie wyświetlała się domyślnie parzysta liczba książek, na przykład 10?
2. Dodajmy do widoku lafelka ID książki (book.id) tuż obok tytułu książki: `Tytuł książki (id obiketu book)`.



------------------------------------------------------------------------------------
## III. Wyszukiwarka (stimulus)

Mamy coraz więcej książek, aby ułatwić użytkownikom szukanie interesujących tytułów, dodajmy wyszukiwarkę.
Wyszukiwarka działać będzie na obecnej stronie, szukamy jak tylko użytkownik wpisze jakikolwiek znak do pola typu input.


1. Zaczynamy od wygenerowania kontrolera js który będzie realizował funkcjonalność wysyłania zapytań, używamy do tego metody `bundle exec rails generate stimulus search`
2. Pojawia się nam nowy plik `app/javascript/controllers/search_controller.js` zobaczmy jak on wygląda:
```
import { Controller } from "@hotwired/stimulus"
// Connects to data-controller="search"
export default class extends Controller {
  connect() {
  }
}
```

3. Aby railsy wiedziały iż ten plik powinny załadować podczas działania serwera, musimy uaktualnić plik manifestu (plik z listą controllerów js), robimy to przez polecenie:
`bundle exec rails stimulus:manifest:update`.
4. W pliku `app/javascript/controllers/index.js` zobaczymy dodany następujący wpis:
```
import SearchController from "./search_controller"
application.register("search", SearchController)
```

5. Mamy obecnie controller.js musimy go połączyć z elementem naszej strony, więc dodajmy do naszej strony pole typu input, w którym uzytkownik będzie mógł wpisać frazę do wyszukiwania.
6. Przechodzimy do `app/views/books/index.html.erb` i pod nagłówkiem h1 dodajemy nowy div z inputem:
```
  <div class='text-center mb-5' data-controller='search'>
    <%= text_field_tag :query,'', placeholder: 'Search by title', data: {action: 'input->search#search', target: 'search.params'}%>
  </div>
```
Co jest tutaj najważniejsze:
* `data-controller='search'` - dzięki temu informujemy jaki kontroler obsługuje to pole
* placeholder - tekst który jest wyświetlany gdy nie ma niczego wprowadzonego
* 'input->search#search' - metoda search w naszym nowym kontrolerze będzie obsługiwać to pole
* target - pod kluczem `params` w kontrolerze będą dostępne dane z pola input

7. Dodatkowo pod nowo dodanym div'em dodajemy miejsce na wyniki wyszukiwania
`<div class="row" id="search_results"></div>`
A także przyda nam się opakowanie całego bloku turbo_frame_tak w div `<div id="infinity_scroll">`.
8. Sprawdzamy czy widzimy nowy element strony w przeglądarce, mamy nowe pole ale nie działa :)
9. Na widoku mamy wszystko gotowe, to teraz czas na zmiany w `app/javascript/controllers/search_controller.js`
10. Tuż pod deklaracją kontrolera dodajemy informacje jakie klucze z parametrami obsługuje kontroler:
```
static targets = ["params"]
```

11. W metodzie search odczytujemy wartość z pola input za pmocą:
```
const value = this.paramsTarget.value
```

12. Następnie tą wartość chcemy użyć do zapytania, aby pobrać dane z 'backendu' Rails, w naszym przypadku controllera books_controller.rb:
```
fetch(`/books/search?search=${value}`, {
      contentType: 'application/json',
      hearders: 'application/json'
    })
    .then((response) => response.text())
    .then(res => {
    })
```

13. Cały plik kontrolera js mam postać:
```
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["params"]

  search() {
    const value = this.paramsTarget.value

    fetch(`/books/search?search=${value}`, {
      contentType: 'application/json',
      hearders: 'application/json'
    })
    .then((response) => response.text())
    .then(res => {
    })
  }
}
```

14. Sprawdzamy czy działa i .... nie działa a w konsoli serwera widzimy blędy. Czegoś nam brakuje.
15. Mamy zmiany na widoku, mamy kontroler js wysyłający zapytania, ale nie mamy 'backendu', który by to zapytanie mógł obsłużyć.
16. W `config/routes.rb` brakuje nam routingu obsługującego path: `/books/search` (metoda GET) i w `app/controllers/books_controller.rb` brakuje nam metody `search`, dodajmy je:
```
# config/routes.rb - resources :books zastępujemy:
resources :books do
  collection do
    get 'search'
  end
end

# app/controllers/books_controller.rb dodajemy metodę search
def search
  @books = Book.where("title LIKE ?", "%#{params[:search]}%")
  respond_to do |format|
    format.json { render json: render_to_string(partial: 'books/index_item', collection: @books, as: :book, formats: [:html])}
  end
end
# używamy tutaj renderowania tego samego partiale co wcześniej już używaliiśmy.
```

17. Restart serwera - bo doszedł nowy routing, sprawdzamy ... i błędów nie ma w logach servera rails, ale nadal nie działa, nic sie nie dzieje.
18. Zapytanie przechodzi ale nic z nim nie robimy, bo tutaj nie ma żadnej akcji w pliku kontrolera `app/javascript/controllers/search_controller.js`:
```
    .then(res => {
    })
```

19. Zmodyfikujmy w następujący sposób:
```
    .then(res => {
      const infinityScroll = document.getElementById("infinity_scroll")
      if(infinityScroll!==null) infinityScroll.remove();

      const searchResults = document.getElementById("search_results")
      searchResults.textContent = ''
      searchResults.insertAdjacentHTML('beforeend', res)
    })
```
W piewszej części wyłączamy infinityScroll jeśli używamy wyszukiwarki, w drugiej czyścimy dane w placeholerze na wyniki i aplikujemy wyniki pobrane z backendu.
20. Sprawdzamy czy działa :)
