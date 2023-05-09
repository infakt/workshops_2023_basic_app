# Wysyłanie logów dotyczących działań użytkownika za pomocą systemu kolejkowania RabbitMQ

## Cel zadania

Chcemy zbierać w osobnej aplikacji zdarzenia/logi dotyczące akcji jaki wykonuje użytkownik korzystający z biblioteki (basic_app).

## Dwa etapy zadania

1. Publikowanie zdarzeń/logów do kolejki rabbitowej
2. Konsumowanie wiadomości z kolejki i zapis zdarzeń w Side_App

## Działamy!

## Instalcja RabbitMQ

MacOS

1. Instalujemy RabbitMQ: `brew install rabbitmq`. Po poprawnej instalacji komenda `brew info rabbitmq`, powinna nam zwrócić informacje na temat wersji Rabbita, używanego portu itp.
2. Aby uruchomić system kolejkowy wpisujemy `brew services start  rabbitmq`, to pozwoli nam uruchomić rabbita lokalnie w tle.
3. Jeśli wszystko pójdzie ok, to pod adresem `http://localhost:15672` powinniśmy zobaczyć panel, do którego logujemy się jako gość, gość ;).

Windows

Debian/Ubuntu

## Bunny - producent wiadomości

1. Do wysyłania zdarzeń do kolejki użyjemy gemu `bunny`. Dodajemy go do naszego Gemfile: `gem 'bunny'` i uruchamiamy `bundle`.
2. I nareszcie kodzik :) . Aby wysłać wiadomość, potrzebujemy najpierw połączyć się z RabbitMQ. W tym celu stworzymy nowy serwis.
Nazwijmy go `Publishers::Application`. Powinien on być inicializowany trzema parametrami:
  - treścią wiadomości (to co będziemy chcieli wyświetlić w drugiej apce)
  - nazwą exchange'a
  - kluczem (routing_key).

3. Główna metoda tego serwisu, z której będziemy korzystać powinna:
  - tworzyć i startować połączenie, przy użyciu `Bunny.new` z opcjami:
    ```
    {
      host: "localhost",
      port: "5672",
      vhost: "/",
      username: "guest",
      password: "guest"
    }
    ```
  - używając połączenia powinna tworzyć tematyczny exchange(`topic`) z nazwą z initializera.
  - dla tego exchange'a publikować przekazaną wiadomość w formacie JSON, na odpowiedni routing_key.
  - zamknąć połączenie

  Na pierwszy rzut oka, moze wydawać się to nieintuicjne, ale tak przygotowany serwis pozwoli nam korzystać z niego w wielu miejscach.

4. A teraz KONKRETY! Chcielibyśmy logować informacje dotyczące wypożyczenia ksiąki. W tym celu stworzymy nowy publisher `Publishers::LoanBook`.
  - publisher przyjmuje w initializerze treść wiaodomości.
  - powinen mieć metodę która wykorzystuje nasz `Publishers::Application`. 
  - UWAGA! tutaj musimy zdefiniować na jaki exchange i routing key będziemy wysyłać wiadomość.
  Ten nazwy będą nam jeszcze dziś potrzebne! :)

5. Ostatnim krokiem jest wpięcie naszego Publishera LoanBook w odpowiednie miejsce w kontrolerze i przekazanie danych.

Podpowiedź: w pierwszej wersji mozemy przesyłać w wiadomość wszystkie parametry dot wypozyczenia uywając metody `attributes`
