# Kaminari - paginacja na liście książek


## Tło
Jak nasza biblioteka się rozrośnie, to aby nie ładować na stronie `Books` wszystkich rekordów wdrożymy paginacje, użyjemy do tego gema [kaminair](https://github.com/kaminari/kaminari)
A następnie zmienimy paginacje w doczytywaną automatycznie liste.


## HOW TO
1. Dodajemy gem `kaminari` (plik Gemfile).
2. Uruchamiamy `bundle` aby nowy gem został zainstalowany.
3. Następnie za pomocą polecenia `bundle exec rails g kaminari:config` dodajemy wymagane elementy konfiguracyjne.
4. Restartujemuy serwer aplikacji.
5. Dodajemy kilka książek tak aby było wszystkich więcej niż 25, warto użyć narzędzia `Faker`, używaliśmy go w seedach.
6. W kontrolerze `app/controllers/books_controller.rb` zmieniamy wywołanie `Book.all` na `Book.page(params[:page])`
7. Aby mieć pewność że nic na tym etapie nie przestało działać, wchodzimy do aplikacji i sprawdzamy czy ładuje się lista książek, ale widzimy tylko 25 rekordów - to dobrze tak powinno być na tym etapie.
8. Dodajemy na widoku `app/views/books/index.html.erb` wpis `<div class="row"><%= paginate @books %></div>` proponuje umieśćić ten wpis po zakończneiu each'a pod znakiem `<% end %>`.
8. Czas na kolejny check, czy aplikacja działa poprawnie i wyświetla się lista z książkami wraz z linkami do kolejnych stron.
9. W tym momencie mamy wdrożoną paginację w naszej aplikacji na liście książek, brawo!
10. Na widoku `app/views/books/index.html.erb` usuwamy dodaną przed chwilą paginacje - nie będzie nam już potrzebna (`<div class="row"><%= paginate @books %></div>`)
11. Aby było łatwiej wprowadzać kolejne zmiany, zmieńmy sposób renderowania elementów z użycia pętli na coś co nam Railsy podrzucaja `<%= render partial: 'index_item', collection: @books, as: :book %>` (to było zadanie dodatkowe we wcześniejszym temacie, jeśli to masz zrobione zapraszam dalej).
12. Kolejny check - sprawdzamy czy aplikacja działa poprawnie i wyświetla się lista z książkami tym razem bez linków do kolejnych stron.
13. Powyżej div'a `<div class="row">` dodajemy turbo_frame_tag <%= turbo_frame_tag "paginate_page_#{@books.current_page}" do %> i kończymy `<% end %>` po zamknięciu div'a:
```
<%= turbo_frame_tag "paginate_page_#{@books.current_page}" do %>
  <div class="row">
    <%= render partial: 'index_item', collection: @books, as: :book %>
  </div>
<% end %>
```
14. Sprawdzamy jak strona wygląda i działa, czy nam czegoś nie brakuje? Tak nic się nie dzieje jak zjedziemy na dół strony, naprawmy to :)
15. Przed zamkniąciem metody turbo_frame_tag dodajemy taki o to wpis:
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
18. Wszystko powyżej działa w taki sposób, że po zejściu na dół strony, pojawia się na moment `loading...` a następnie turbo pobiera z adresu ktory przekazaliżmy jako `src` nowe dane i umieszcza je na stronie. Robi to aż do momentu jak wystepuje kolejny numer strony (if dotyczący next_page).
19. Mamy to! Strona działa jak zaplanowaliśmy :)


## Zadanie dodatkowe dla chętnych:
1. Jak możemy zrobić, aby na stronie wyświetlała się domyślnie parzysta liczba książek, na przykład 10?
