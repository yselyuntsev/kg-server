defmodule KeyGuard.Factory do
  use ExMachina.Ecto, repo: KeyGuard.Repo

  def key_factory() do
    %KeyGuard.Keys.Key{
      id: sequence(:id, &"super-unique-key-id-#{&1}"),
      name: sequence(:name, &"key-#{&1}"),
      color: sequence(:color, ["red", "blue", "black"]),
      extra: "Some extra info"
    }
  end

  def key_access_factory() do
    %KeyGuard.Keys.KeyAccess{
      access_type: sequence(:access_type, [true, false]),
      employee: build(:employee),
      key: build(:key)
    }
  end

  def keys_journal_factory() do
    %KeyGuard.Keys.KeysJournal{
      taken_by_employee: build(:employee),
      returned_by_employee: build(:employee),
      taken_at: Timex.now(),
      returned_at: Timex.now(),
      key: build(:key)
    }
  end

  def employee_factory() do
    %KeyGuard.Staff.Employee{
      first_name: "Bruce",
      last_name: "Wayne",
      patronym: "Batman",
      card: sequence(:card, &"card-number-#{&1}"),
      encoded_photo:
        "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg=="
    }
  end

  def unit_factory() do
    %KeyGuard.Units.Unit{
      name: sequence(:name, &"Unit name #{&1}")
    }
  end

  def user_factory() do
    %KeyGuard.Admin.User{
      username: sequence(:username, &"user_#{&1}"),
      role: KeyGuard.Admin.User.role(:superadmin),
      password: "password",
      hashed_password: Comeonin.Bcrypt.hashpwsalt("password"),
      token: sequence(:token, &"AJSDLKJDei98u7r893uiojkljasd#{&1}")
    }
  end
end
