# Wysyłanie logów po zalogowaniu i wylogowaniu użytkownika

## Cel zadania

Chcemy wysyłać log w momencie kiedy użytkownik zaloguje się do aplikacji i kolejny log kiedy użytkownik się wyloguję. Chcemy wysyłać te logi na ten sam exchange, ale na inną kolejkę.

## Basic App

1. Publisher do Logowania Logowania :)

W folderze `/publishers` stwórzmy publisher `UserLogIn`. Stwórzmy go na wzór publishera z poprzedniega zadania. Powinen w initlializerze przyjmować message/dane, które przekażemy do Side_app. 

W publicznej metodzie wykorzystajmy `::Publishers::Application`, w inicjalizerze będzie miał
- message
- exchage -> taki sami jak przy wypożyczeniu!
- routing_key -> tutaj wpiszmy `user.log.in` zaraz zobaczymy dlaczego ;)

2. Publisher do Logowania Wylogowanie

W folderze `/publishers` stwórzmy publisher `UserLogOut`.
Reszta będzie taka sama oprócz **routing_key**, tym razem będzie to `user.log.out`.

Teraz potrzebujemy wpiąć Publishery w odpowiednie miejsca

3. Wpięcie publishera po Logowaniu

Tutaj będzie trochę kombinacji ;)
W związku z tym, że korzystamy z gemu Devise, będziemy potrzebowali stworzyć dodatkowy kontroler, który dziedziczy metody devisowe.
(`SessionsController < Devise::SessionsController`)

Tworzymy `::Users::SessionsController` pod ścieżką `controllers/users/sessions_controller.rb`.

W nim potrzebujemy użyć callbacku* `after_action`.

*callback `after_action` -> wg oficjalnej dokumentacji jest to `filter` https://guides.rubyonrails.org/action_controller_overview.html#filters,

`after_action` potrzebuje dwóch aprametrów, metody i akcji na po której zostanie wykonana metoda

W naszym przypadku dla logowania może to wyglądać tak:

```
  after_action :sign_in_log, only: :create

  def sign_in_log
    # PUSH LOG
  end

```
Jako message przekażemy do `::Publishers::UserLogIn` w hashu dane: Id usera, email usera i obecny czas, jak datę wydarzenia.

```
  @load_log_data ||= {
    user_id: @user.id,
    user_email: @user.email,
    published_at: ::Time.zone.now
  }
```

W zasadzie jesteśmy gotowi do przetestowania. ale!

Skoro nadpisaliśmy controller devisowy to musimy zmienić jeszcze routes.rb

podmieniamy poprzedni wpis `devise_for :users` na:

`devise_for :users, controllers: { sessions: 'users/sessions' }`

4. 

Analogicznie potrzebujemy dodać metodę na wylogowanie, dla akcji `:destroy`.
W dodanych przez nas metodach, potrzebujemy wywołać `::Publishers::UserLogIn` i `::Publishers::UserLogOut`.


Uwaga te dane będą dostępne tylko dla akcji Logowania!

Dla wy

