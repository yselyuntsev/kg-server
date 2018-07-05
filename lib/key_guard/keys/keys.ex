defmodule KeyGuard.Keys do
  @moduledoc "Keys context functions."

  alias KeyGuard.Repo
  alias KeyGuard.Keys.{Key, KeyAccess, KeysJournal}
  alias KeyGuard.Keys.Key.Validator, as: KeyValidator
  alias KeyGuard.Keys.KeyAccess.Validator, as: KeyAccessValidator
  alias KeyGuard.Staff.Employee
  alias KeyGuard.Units.Unit
  import Ecto.Query, only: [from: 2]

  @doc "Returns all keys."
  @spec all_keys() :: [%Key{}]
  def all_keys(), do: Repo.all(Key)

  @doc "Finds a key by given ID or returns nil when key isn't exits."
  @spec find_key(String.t()) :: %Key{} | nil
  def find_key(key_id), do: Repo.get(Key, key_id)

  @doc "Return all taken keys by employee ID"
  @spec taken_keys(String.t()) :: [%KeysJournal{}]
  def taken_keys(employee_id), do: from(k in KeysJournal, where: k.taken_by == ^employee_id and is_nil(k.returned_by)) |> Repo.all()

  @doc "Return all taken keys"
  @spec all_taken_keys() :: [%KeysJournal{}]
  def all_taken_keys(), do: from(k in KeysJournal, where: is_nil(k.returned_by)) |> Repo.all()

  @doc "Return all keys access"
  @spec all_keys_access() :: [%KeyAccess{}]
  def all_keys_access(), do: Repo.all(KeyAccess)

  @doc "Finds a key access by given ID or returns nil when key access isn't exits."
  @spec find_key_access(non_neg_integer) :: %KeyAccess{} | nil
  def find_key_access(key_access_id), do: Repo.get(KeyAccess, key_access_id)

  @doc "Finds a key access by given employee ID or returns nil when key access isn't exits."
  @spec find_key_access_by_employee_id(non_neg_integer) :: [%KeyAccess{}]
  def find_key_access_by_employee_id(employee_id), do: from(k in KeyAccess, where: k.employee_id == ^employee_id) |> Repo.all()

  @doc """
  Creates a key.
  The function takes `params` arg and returns one of:
    * `{:ok, key}` - when key was successfully created;
    * `{:error, changeset}` - when params are invalid.

  ### Example:
      params = %{"id" => "key-id", name: "key name", "color" => "red", "extra" => "Some extra info (not required)"}
      Keys.create_key(params)
  """
  @spec create_key(map) :: {:ok, %Key{}} | {:error, Ecto.Changeset.t()}
  def create_key(params), do: %Key{} |> KeyValidator.create_changeset(params) |> Repo.insert()

  @doc """
  Updates a key.
  The function takes `key` and `params` args and returns one of:
    * `{:ok, key}` - when key was successfully updated;
    * `{:error, changeset}` - when params are invalid.

  ### Example:
      key = Repo.get(Key, key_id)
      params = %{name => "new key name", "color" => "blue", "extra" => "New extra info"}
      Keys.update_key(key, params)
  """
  @spec update_key(%Key{}, map) :: {:ok, %Key{}} | {:error, Ecto.Changeset.t()}
  def update_key(key, params), do: key |> KeyValidator.update_changeset(params) |> Repo.update()

  @doc "Deletes a key."
  @spec delete_key!(%Key{}) :: %Key{} | no_return
  def delete_key!(key), do: Repo.delete!(key)

  @doc """
  Creates a key access for given key and employee.
  The function takes `key`, `employee` and `params` arg and returns one of:
    * `{:ok, key_access}` - when key access was successfully created;
    * `{:error, changeset}` - when params are invalid.

  `key_access` field in `params` arg can be `true` or `false`.
  `false` type is disallows an employee to take given key.
  `true` type is allows an employee to take given key.

  ### Example:
      key = Repo.get(Key, key_id)
      employee = Repo.get(Employee, employee_id)
      params = %{"access_type" => true}
      Keys.add_access_to_key(key, employee, params)
  """
  @spec add_access_to_key(%Key{}, %Employee{}, map) :: {:ok, %KeyAccess{}} | {:error, Ecto.Changeset.t()}
  def add_access_to_key(key, employee, params) do
    complete_params = Map.merge(params, %{"key_id" => key.id, "employee_id" => employee.id})
    %KeyAccess{} |> KeyAccessValidator.create_changeset(complete_params) |> Repo.insert()
  end

  @doc """
  Updates a key access.
  The function takes `key_access` and `params` args and returns one of:
    * `{:ok, key_access}` - when key access was successfully updated;
    * `{:error, changeset}` - when params are invalid.

  ### Example:
      key_access = Repo.get(KeyAccess, key_access_id)
      params = %{"access_type" => false}
      Keys.update_key_access(key_access, params)
  """
  @spec update_key_access(%KeyAccess{}, map) :: {:ok, %KeyAccess{}} | {:error, Ecto.Changeset.t()}
  def update_key_access(key_access, params),
    do: key_access |> KeyAccessValidator.update_changeset(params) |> Repo.update()

  @doc "Deletes a key access."
  @spec delete_key_access!(%KeyAccess{}) :: %KeyAccess{} | no_return
  def delete_key_access!(key_access), do: Repo.delete!(key_access)

  @doc """
  Adds given key to given unit.
  The function takes `key` and `unit` args and returns one of:
    * `{:ok, key, unit}` - when key was successfully added to unit;
    * `{:error, :already_exists}` - when relationship between given key and unit is already exists.

  ### Example:
      key = Repo.get(Key, key_id)
      unit = Repo.get(Unit, unit_id)
      Keys.add_to_unit(key, unit)
  """
  @spec add_to_unit(%Key{}, %Unit{}) :: {:ok, %Key{}, %Unit{}} | {:error, :already_exists}
  def add_to_unit(%Key{id: key_id} = key, %Unit{id: unit_id} = unit) do
    case Repo.insert_all("unit_keys", [%{key_id: key_id, unit_id: unit_id}], on_conflict: :nothing) do
      {1, nil} -> {:ok, key, unit}
      _ -> {:error, :already_exists}
    end
  end

  @doc """
  Removes given key from given unit.
  The function takes `key` and `unit` args and returns one of:
    * `{:ok, key, unit}` - when key was successfully removed from unit;
    * `{:error, :not_in_unit}` - when relationship between given key and unit isn't exists.

  ### Example:
      key = Repo.get(Key, key_id)
      unit = Repo.get(Unit, unit_id)
      Keys.remove_from_unit(key, unit)
  """
  @spec remove_from_unit(%Key{}, %Unit{}) :: {:ok, %Key{}, %Unit{}} | {:error, :not_in_unit}
  def remove_from_unit(%Key{id: key_id} = key, %Unit{id: unit_id} = unit) do
    query = from(u in "unit_keys", where: u.unit_id == ^unit_id and u.key_id == ^key_id)

    case Repo.delete_all(query) do
      {1, nil} -> {:ok, key, unit}
      _ -> {:error, :not_in_unit}
    end
  end

  @doc """
  Takes or returns a key.
  The function takes `key` and `employee` args and returns one of:
    `{:ok, keys_journal}` - when key was successfully taked or returned;
    `{:error, :no_access}` - when employee has no access to given key.

  When key not taken and employee has access to take the key, new `%KeysJournal{}` record will be created.
  When key is already taken, but not returned,
  key will be returned by `%KeysJournal{}` updating (by setting `returned_at` and `returned_by` fields).

  Employee can take key in two cases: when he has allowed key access for this key
  and when he associated with same unit as a key.

  Employee can't take key when he has disallowed key access for this key
  and when he isn't associated with same unit as a key.

  ### Example:
      key = Repo.get(Key, key_id)
      employee = Repo.get(Employee, employee_id)
      Keys.take_or_return_key(key, unit)
  """
  @spec take_or_return_key(%Key{}, %Employee{}) :: {:ok, %KeysJournal{}} | {:error, :no_access}
  def take_or_return_key(key, employee) do
    not_returned_key = from(k in KeysJournal, where: k.key_id == ^key.id and is_nil(k.returned_at)) |> Repo.one()
    if not_returned_key, do: return_key(not_returned_key, employee), else: take_key(key, employee)
  end

  defp return_key(keys_journal, employee),
    do: Ecto.Changeset.change(keys_journal, returned_by: employee.id, returned_at: Timex.now()) |> Repo.update()

  defp take_key(key, employee) do
    key_access = Repo.get_by(KeyAccess, key_id: key.id, employee_id: employee.id)

    cond do
      not is_nil(key_access) && key_access.access_type == true -> do_take_key(key, employee)
      is_nil(key_access) && in_same_unit?(key, employee) -> do_take_key(key, employee)
      true -> {:error, :no_access}
    end
  end

  defp in_same_unit?(key, employee) do
    key_unit_ids = Repo.preload(key, :units).units |> Enum.map(& &1.id)

    same_units_count =
      from(
        e in "employee_units",
        where: e.employee_id == ^employee.id and e.unit_id in ^key_unit_ids,
        select: count(e.id)
      )
      |> Repo.one()

    same_units_count > 0
  end

  defp do_take_key(key, employee) do
    Repo.insert(%KeysJournal{
      key_id: key.id,
      taken_by: employee.id,
      taken_at: Timex.now(),
      returned_at: nil,
      returned_by: nil
    })
  end
end
