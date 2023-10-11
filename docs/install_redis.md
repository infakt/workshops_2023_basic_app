# Instalacja Redisa

Do uruchomienia Sidekiqa, którego będziemy dzisiaj używać, potrzebujemy Redisa. Redis to specjalna baza danych przechowująca dane w postaci par klucz-wartość, w pamięci RAM. Sidekiq używa go do przechowywania zadań i innych danych.

## MacOS

Wykonujemy w terminalu polecenie `brew install redis`. Po poprawnej instalacji wywołujemy `redis-server`(ew. `brew services start redis`). Jeżeli widzisz w terminalu logo Redisa (pudełko 🙂) i komunikat `Ready to accept connections` - jest ok. Zostawiamy uruchomiony serwer - to wszystko. :)

## Linux

W zależności od używanej dystrybucji instalujemy Redisa za pomocą naszego managera paczek (być może jest już zainstalowany - możesz sprawdzić jego wersję poleceniem `redis-server --version` - minimalna wersja potrzebna do uruchomienia Sidekiq to 6.2). Po poprawnej instalacji wywołujemy `redis-server`. Jeżeli widzisz w terminalu logo Redisa (pudełko 🙂) i komunikat `Ready to accept connections` - jest ok. Zostawiamy uruchomiony serwer - to wszystko. :)

## Ubuntu

Na Ubuntu często Redis jest już zainstalowany - niestety w zbyt niskiej wersji. Żeby rozwiązać ten problem musimy go odinstalować i zainstalować ponownie przy pomocy innego managera paczek - takiego, w którym jest dostępna nowsza wersja:

```
sudo apt-get purge --auto-remove redis-server
sudo snap install redis
```

Po instalacji możemy uruchomić go poleceniem `sudo snap start redis`.

## Windows

Pobieramy [zip](https://github.com/ZeroSlayer/redis-6.2.3-stable-windows-64bit/archive/refs/heads/master.zip). Jest to port - Redis nie jest natywnie wspierany przez Windows. Po rozpakowaniu archiwum wystarczy, że uruchomisz dwuklikiem plik `redis-server` z katalogu `bin`. Jeżeli widzisz w terminalu logo Redisa (pudełko 🙂) i komunikat `Ready to accept connections` - jest ok. Zostawiamy uruchomiony serwer - to wszystko. :)
