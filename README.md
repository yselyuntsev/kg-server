# SKUD Server

> Elixir + Phoenix framework | Cервер СКУД "Выдача ключей"

### Для запуска Phoenix сервера необходимо:

  * Установить зависимости выполнив: `mix deps.get`
  * Создать и выполнить миграции в базу данных: `mix ecto.create && mix ecto.migrate`
  * Установить Node.js зависимости выполнив: `cd assets && npm install`
  * Запустить сервер с помощью команды: `mix phx.server`

Теперь сервер запущен и доступен по адресу [`localhost:4000`](http://localhost:4000).

---

### Создание администратора

Для создания администратора необходимо запустить консоль elixir с помощью команды: `iex -S mix`

Далее выполнить две команды:`alias KeyGuard.repo` и `alias KeyGuard.Admin.User`

Добавляем администратора выполнив следующую команду:
`Repo.insert(%User{username: "<Имя пользователя>", token: "<Токен авторизации>", role: 2, hashed_password: Comeonin.Bcrypt.hashpwsalt("<Пароль пользователя>")}) `

---

### Тестирование приложения

Для запуска unit-тестов запустите команду: `mix test`

---

СКУД "Выдача ключей" 2018г.
