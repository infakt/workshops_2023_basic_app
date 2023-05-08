# Integracja aplikacji z API pogodowym

## Cel zadania

Chcemy połączyć naszą aplikację w Ruby on Rails z API pogodowym dostarczanym przez https://www.weatherapi.com, aby:
- wyświetlić bieżące dane pogodowe w aplikacji,
- wyświetlić odpowiedni tekst uzależniony od pogody.

## Dwa etapy zadania

1. Założymy konto w serwisie dostarczający API z danymi o pogodzie i uzyskamy klucz API.
2. Dokonamy zmiany w aplikacji, aby odpowiednio pozyskać dane i wyświetlić je w aplikacji.

## Działamy!

## Etap 1 - pozyskanie klucza API

1. Wchodzimy na stronę https://www.weatherapi.com/signup.aspx i zakładamy darmowe konto.
2. Potwierdzamy konto (na maila przyjdzie link, w który należy kliknąć).
3. Tu mamy informacje dot. korzystania z API i przydatne linki, np. do dokumentacji API https://www.weatherapi.com/my/ oraz mamy podany wygenerowany automatycznie klucz API, kopiujemy sobie gdzieś ten klucz, bedziemy z niego później korzystać.
4. Tu mamy kilka przydatnych linków, aby zapoznać się z tym jak działa API: 
 - api explorer: https://www.weatherapi.com/api-explorer.aspx
 - dokumentacja: https://www.weatherapi.com/docs/
5. Korzystamy dla rozeznania z API explorer, podajemy swój klucz API, pozostawiamy pozostałe opcje (http i json) i klikamy “Show response” dla bieżącej pogody (zakładką “current”), bo z takiej bedziemy korzystać.
6. Możemy też wpisać w przeglądarkę bezpośrednio nasz przykładowy request (z wstawionym naszym kluczem API) i zobaczyć jakie dane otrzymujemy, natomiast nie będziemy ze wszystkich korzystać, wyciągniemy tylko te, których chcemy uzyć.

## Etap 2 - wdrożenie danych pogodowych w aplikacji

1. Wychodzimy z najnowszego brancha głównego `main` i tworzymy swój branch na zmiany, np. `weather_api`.
2. Chcemy skorzystać z nastepujących informacji (te dane musimy wyłuskać z odpowiedzi na nasz request):
 - temperatura
 - tekstowy opis
 - ikonka pokazująca graficzną reprezentację opisu
3. Tworzymy serwis, który bedzie nam pobierał komplet bieżących danych pogodowych `app/services/weather_api_connector.rb`.
4. Tu przykładowy artykuł listujący metody tworzenia requestów do API https://www.twilio.com/blog/5-ways-make-http-requests-ruby, skorzystamy z tej pierwszej.
5. Wartości przekazujące klucz API oraz lokalizację możemy zapisac do stałych (lub zapisać je w innym miejscu korzystając z gema A9n, rozpracujemy to w kolejnym zadaniu więc potem mozesz to ulepszyć).
6. Tworzymy metodę, która wykona request na odpowiedni adres z parametrami, jakie ustalimy a nastepnie zapisze pod zmienną `@data` dane odpowiedzi:
```
def weather_data
  url = "http://api.weatherapi.com/v1/current.json?key=#{API_KEY}&q=#{LOCATION}"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  @data = JSON.parse(response)
end
```
7. Aby ładnie zaprezentować nasze dane pogodowe i tylko te, które sobie zaplanowaliśmy korzytamy z nowej warstwy abstrakcji i tworzymy presenter `app/presenters/weather_presenter.rb`.
8. W presenterze, bazując na danych z serwisu zwracającego odpowiedź z API pogodowego, tworzymu metody:
 - wyciągające określone dane z całego zestawu: `description`, `temperature`, `icon`
 - w dokumentacji możemy znaleźć zestaw wszystkich możliwych danych opisowych, jakie możemy otrzymać w zwrotce, po ich przejrzeniu można ustalić, ze ładna pogoda jest gdy:
```
def nice_weather?
  description == 'Sunny' || 'Partly cloudy'
end
```
  - biorąc pod uwagę część opisową jak i wartość liczbową dla stopni temperatury możemy się umówić, ze ładna pogoda jest, gdy jest słonecznie lub częściowo zachmurzone niebo oraz temperaturajest wyższa niz 15 stopni:
```
def good_to_read_outside?
  nice_weather? && temperature > 15
end
```
- bazując na wyniku powyższej metody możemy zaproponowac teksty, które będziemy wyświetlać w aplikacji obok danych pogodowych dla naszej lokalizacji:
```
def encourage_text
  if good_to_read_outside?
    "Get some snacks and go read a book in a park!"
  else
    "It's always a good weather to read a book!"
  end
end
```
9. Tworzymy plik widoku `app/views/weather/show.html.erb`, w którym możemy bazować na metodach z naszego presentera, aby zdynamizować wyświetlane treści.
10. Plik ten musimy wywołać w głównym layoucie aplikacji, z racji, ze chcemy, aby element ten wyświetlał się na każdej ze stron, dodajemy więc do `app/views/layouts/application.html.erb` dodatkowy div, w którym bedziemy renderować nasz widok pogody, należy pamiętać, aby w `locals` uzyć presentera, z którego metod korzystamy:
```
<div class="container">
  <%= render template: "weather/show", locals: { presenter: @presenter } %>
</div>
```
11. Dla dopracowania finalnego efektu wizualnego, ułożenia naszego elementu pogodowego mozemy podziałać ze stylami bootstrapa, tutaj dokumentacja https://getbootstrap.com/docs/3.4/css/.
12. Jeśli jako efekt końcowy widzisz bieżące dane pogodowe wraz z tekstem zachęcającym do czytania to właśnie udało Ci się zakończyć pierwsze zadanie.






