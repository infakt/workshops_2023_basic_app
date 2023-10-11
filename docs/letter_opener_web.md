# Podgląd maili testowych na własnym serwerze

## Tło

Jeżeli komuś maile **zapisywały się  do folderu tmp/letter_opener**, ale **nie otwierały w przeglądarce** - można dopiąć sobie wygodny, przeglądarkowy podgląd tych maili - gem [letter_opener_web](https://github.com/fgrehm/letter_opener_web).

Jest to nakładka, która po prostu "podgląda" ten folder i prezentuje jego zawartość w przystępny sposób:

![image](https://github.com/infakt/workshops_2023_basic_app/assets/13132306/b365704b-a0e4-4815-8816-fac4005822b4)

## HOW TO

1. Dodajemy gem [letter_opener_web](https://github.com/fgrehm/letter_opener_web) do gemfile'a, **w tym samym miejscu** (pod) co `letter_opener` (w grupie development) i wykonujemy polecenie `bundle install`.
2. Dopinamy sobie ścieżkę do podglądu maili, w naszych routesach:
```
Rails.application.routes.draw do
#....
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
```
3. **Restartujemy serwer!**
4. Testujemy - zamiast się zalogować, klikamy "Forgot your password?" i "wysyłamy" sobie z Devise'a maila (albo jakiegokolwiek innego maila, np. z konsoli. ;) )
5. Wchodzimy pod adres [http://localhost:3000/letter_opener](http://localhost:3019/letter_opener) - TADAM! Powinny tam być nasze maile.
