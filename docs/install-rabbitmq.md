# Instalcja RabbitMQ

## MacOS

1. Instalujemy RabbitMQ: `brew install rabbitmq`. Po poprawnej instalacji komenda `brew info rabbitmq`, powinna nam zwrócić informacje na temat wersji Rabbita, używanego portu itp.
2. Aby uruchomić system kolejkowy wpisujemy `brew services start  rabbitmq`, to pozwoli nam uruchomić rabbita lokalnie w tle.
3. Jeśli wszystko pójdzie ok, to pod adresem `http://localhost:15672` powinniśmy zobaczyć panel, do którego logujemy się jako gość, gość ;).

## Windows

1. Do instalacji i uruchomienia RabbitMQ, będziemy w pierwszej kolejności potrzebowali mieć zainstalowany Erlang.
    Od Wersji Erlanga którą zainstalujecie będzie zalezało jaką wersje RabitMQ będzie mozna zainstalować. 
    Tabela sprawdzjąca wersję Rabbita i Erlanga https://www.rabbitmq.com/which-erlang.html

    Uwaga. W systemie powinna być zainstalowana tylko jedna wersja Erlanga

    Sprawdzanie wersji:

    Jeśli mamy juz zainstalowanego Erlanga to uruchamiamy go dwuklikiem, powinno otworzyć się okno z info np:

    ```
      Erlang (BEAM) emulator version 5.0.1 [threads]

      Eshell V5.0.1  (abort with ^G)
      1>
    ```

    W przypadku braku Erlanga, mozemy go pobrac z linku:

    Zainstalumy wersję 25.3.2 -> https://github.com/erlang/otp/releases/download/OTP-25.3.2/otp_win64_25.3.2.exe

    ze strony https://erlang.org/download/otp_versions_tree.html

    Po instalacji nalezy zrestarować komputer.
2. Jeśli mamy ju zainstalowanego Erlanga, mozemy pobrac i zainstalować serwer RabbitMQ https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.11.15/rabbitmq-server-3.11.15.exe
3. Włączenie Pluginu do zarządzanie RabbitMQ: (https://docs.servicestack.net/install-rabbitmq-windows#enable-rabbit-mq-s-management-plugin)

  w konsoli wpisujemy: 
  `"C:\Program Files (x86)\RabbitMQ Server\rabbitmq_server-3.11.15\sbin\rabbitmq-plugins.bat" enable rabbitmq_management`

  Uwaga, ściezka moze byc rozna w Waszym systemie np bez (x86)

  restartujemy serwer w konsoli: `net stop RabbitMQ && net start RabbitMQ` UWAGA! konsola w trybie administratora!

  Server mozemy tez uruchomic wyszukujac polecenie `RabbitMQ Command Prompt`

4. Jeśli wszystko pójdzie ok, to pod adresem `http://localhost:15672` powinniśmy zobaczyć panel, do którego logujemy się jako gość, gość ;).


## Ubuntu/Debian

1. https://computingforgeeks.com/how-to-install-latest-rabbitmq-server-on-ubuntu-linux/ -> najpierw instalacje erlanga a później rabbita



