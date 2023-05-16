# Instalacja Redisa

Do uruchomienia Sidekiqa, którego będziemy dzisiaj używać, potrzebujemy Redisa. Redis to specjalna baza danych przechowująca dane w pamięci RAM. Sidekiq używa go do przechowywania zadań i innych danych.

## MacOS

Wykonujemy w terminalu polecenie `brew install redis`. Po poprawnej instalacji wywołujemy `redis-server`. Jeżeli widzisz w terminalu logo Redisa (pudełko 🙂) i komunikat `Ready to accept connections` - jest ok. Zostawiamy uruchomiony serwer - to wszystko. :)

## Linux

W zależności od używanej dystrybucji instalujemy redisa za pomocą naszego managera paczek, np. dla Ubuntu `sudo apt-get install redis`. Po poprawnej instalacji wywołujemy `redis-server`. Jeżeli widzisz w terminalu logo Redisa (pudełko 🙂) i komunikat `Ready to accept connections` - jest ok. Zostawiamy uruchomiony serwer - to wszystko. :)

## Windows

Pobieramy [zip](https://github.com/ZeroSlayer/redis-6.2.3-stable-windows-64bit/archive/refs/heads/master.zip). Jest to port - Redis nie jest natywnie wspierany przez Windows. Po rozpakowaniu archiwum wystarczy, że uruchomisz dwuklikiem plik `redis-server` z katalogu `bin`. Jeżeli widzisz w terminalu logo Redisa (pudełko 🙂) i komunikat `Ready to accept connections` - jest ok. Zostawiamy uruchomiony serwer - to wszystko. :)
