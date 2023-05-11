# Przepięcie na swoje repo po sklonowaniu repo inFakt

## Tło

Jeżeli na warsztatach **sklonowałeś/aś** repo https://github.com/infakt/workshops_2023_basic_app i teraz chcesz móc pushować do prywatnego - **ta instrukcja jest dla Ciebie!**

Wytłumaczenie:

**CLONOWANIE** - clonowanie służy do **wspólnego** rozwijania tego samego projektu. W naszej sytuacji - chcemy, żeby każdy uczestnik rozwijał aplikację indywidualnie (realizujecie te same zadania, więc nie da rady inaczej ;) )

**FORKOWANIE** - forkowanie służy do "wykorzystania" danego kodu źródłowego, ale rozwijania go "dalej po swojemu"

Przykład:
* jeżeli chcielibyście rozwijać repozytorium Railsów - dla całego community, oficjalne - sklonowalibyście to repo (ofc - wtedy trzeba mieć uprawnienia, żeby pushować najczęśniej, nie ma tak prosto ;) )
* jeżeli natomiast chcielibyście napisać "własne Railsy na bazie istniejących" - wtedy forkujecie!

## HOW TO

1. Zakładam, że lokalnie masz katalog, sklonowane repo `workshops_2023_basic_app`
2. Będąc zalogowany do **swojego prywatnego** konta na githubie - przechodzisz https://github.com/infakt/workshops_2023_basic_app i klikasz "FORK", następnie akceptujesz - w ten sposób utworzysz **na swoim koncie** nowe repo, które będzie miało ten sam kod, co nasze bazowe:)
3. Idziemy do konsoli!
4. W konsoli przechodzimy do repo (do głównego katalogu aplikacji)
5. Wylistujmy sobie zdalne repozytoria:
`git remote -v`
Powinno pojawić się coś takiego:
```
origin	https://github.com/infakt/workshops_2023_basic_app.git (fetch)
origin	https://github.com/infakt/workshops_2023_basic_app.git (push)
```
Jak widać tzw `origin` czyli domyślne zdalne repozytorium - jest ustawione na **infakt**
6. Zmieńmy nazwę tego zdalnego repozytorium na `infakt`, żeby nie stracić do niego referencji
`git remote rename origin infakt`
Wylistujmy ponownie `git remote -v`
Powinno pojawić się coś takiego:
```
infakt	https://github.com/infakt/workshops_2023_basic_app.git (fetch)
infakt	https://github.com/infakt/workshops_2023_basic_app.git (push)
```

7. Ok, teraz czas dodać **Twoje** repo jako domyślne
Poniższy kod zależy od Twojej nazwy użytkownika i czy forkowałeś/łaś z domyślnymi wartościami.
Np dla usera na githubie Dellilah:
`git remote add origin git@github.com:Dellilah/workshops_2023_basic_app.git`

8. W ten sposób udało się zmienić domyślne, zdalne repo, zostawiając nawiązanie do infakt-owego!
`git remote -v`
```
infakt	https://github.com/infakt/workshops_2023_basic_app.git (fetch)
infakt	https://github.com/infakt/workshops_2023_basic_app.git (push)
origin	git@github.com:Dellilah/workshops_2023_basic_app.git (fetch)
origin	git@github.com:Dellilah/workshops_2023_basic_app.git (push)
```

9. Sprawdź czy możesz wypushować swoje zmiany, do swojego repo!
