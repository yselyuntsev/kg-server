defmodule KeyGuard.KeysTest do
  use KeyGuard.DataCase
  alias KeyGuard.{Repo, Keys}
  alias KeyGuard.Keys.{Key, KeyAccess, KeysJournal}
  alias KeyGuard.Units.Unit
  import KeyGuard.Factory
  import Ecto.Query, only: [from: 1, from: 2]

  setup do
    key = insert(:key, color: "red")
    key_access = insert(:key_access)

    {:ok, key: key, key_access: key_access}
  end

  describe "find_key/1" do
    test "finds a key by given id", %{key: %Key{id: key_id}} do
      assert %Key{id: ^key_id} = Keys.find_key(key_id)
    end

    test "returns nil when key with given id isn't exists" do
      assert Keys.find_key("fake-id") == nil
    end
  end

  describe "find_all_keys_access/0" do
    setup _ctx do
      from(k in KeyAccess) |> Repo.delete_all()
      insert_list(5, :key_access)
      :ok
    end

    test "returns all keys access" do
      keys_access = Keys.all_keys_access()
      assert [%KeyAccess{} | _] = keys_access
      assert Enum.count(keys_access) == 5
    end
  end

  describe "find_key_access_by_employee_id/1" do

    test "return all key access by employee id", %{key_access: %KeyAccess{employee_id: employee_id}} do
      key_access = Keys.find_key_access_by_employee_id(employee_id)
      assert [%KeyAccess{} | _] = key_access
    end
  end

  describe "find_key_access/1" do
    test "finds a key access by given id", %{key_access: %KeyAccess{id: key_access_id}} do
      assert %KeyAccess{id: ^key_access_id} = Keys.find_key_access(key_access_id)
    end

    test "returns nil when key access with given id isn't exists" do
      assert Keys.find_key_access(0) == nil
    end
  end

  describe "create_key/1" do
    test "with valid params" do
      params = %{
        "id" => "some-unique-id",
        "name" => "Key name",
        "color" => "red",
        "extra" => "Some extra information"
      }

      assert {:ok, %Key{} = key} = Keys.create_key(params)
      assert key.id == params["id"]
      assert key.name == params["name"]
      assert key.color == params["color"]
      assert key.extra == params["extra"]
    end

    test "with invalid params" do
      params = %{"id" => "new-key-id"}
      assert {:error, %Ecto.Changeset{}} = Keys.create_key(params)
      refute Repo.get(Key, params["id"])
    end
  end

  describe "update_key/2" do
    test "with valid params", %{key: key} do
      params = %{
        "id" => "new-id",
        "name" => "New key name",
        "color" => "black",
        "extra" => "New extra information"
      }

      assert {:ok, %Key{} = updated_key} = Keys.update_key(key, params)
      assert updated_key.name == params["name"]
      assert updated_key.color == params["color"]
      assert updated_key.extra == params["extra"]

      # It's not possible to update key id
      refute updated_key.id == params["id"]
      assert updated_key.id == key.id
    end

    test "with invalid params", %{key: key} do
      params = %{"name" => "New name", "color" => nil}
      assert {:error, %Ecto.Changeset{}} = Keys.update_key(key, params)

      # Check that key wasn't updated
      not_updated_key = Repo.get(Key, key.id)
      refute not_updated_key.name == params["name"]
      assert not_updated_key.name == key.name
    end
  end

  describe "delete_key!/1" do
    test "delete a key", %{key: %{id: key_id} = key} do
      assert %Key{id: ^key_id} = Keys.delete_key!(key)
      refute Repo.get(Key, key_id)
    end
  end

  describe "add_access_to_key/3" do
    setup _ctx do
      employee = insert(:employee)
      [employee: employee]
    end

    test "allow an employee to take given key", ctx do
      assert {:ok, %KeyAccess{} = key_access} = Keys.add_access_to_key(ctx.key, ctx.employee, %{"access_type" => true})
      assert key_access.key_id == ctx.key.id
      assert key_access.employee_id == ctx.employee.id
      assert key_access.access_type == true
    end

    test "disallow an employee to take given key", ctx do
      assert {:ok, %KeyAccess{} = key_access} = Keys.add_access_to_key(ctx.key, ctx.employee, %{"access_type" => false})
      assert key_access.key_id == ctx.key.id
      assert key_access.employee_id == ctx.employee.id
      assert key_access.access_type == false
    end

    test "an employee can't have two access rules for given key", ctx do
      assert {:ok, %KeyAccess{}} = Keys.add_access_to_key(ctx.key, ctx.employee, %{"access_type" => true})
      assert {:error, %Ecto.Changeset{}} = Keys.add_access_to_key(ctx.key, ctx.employee, %{"access_type" => false})
      assert from(k in KeyAccess, where: k.key_id == ^ctx.key.id, select: count(k.id)) |> Repo.one!() == 1
    end
  end

  describe "update_key_access/2" do
    setup do
      key_access = insert(:key_access, access_type: true)
      {:ok, key_access: key_access}
    end

    test "with valid params", %{key_access: key_access} do
      assert {:ok, %KeyAccess{} = updated_key_access} = Keys.update_key_access(key_access, %{"access_type" => false})
      assert updated_key_access.access_type == false
    end

    test "with invalid params", %{key_access: key_access} do
      assert {:error, %Ecto.Changeset{}} = Keys.update_key_access(key_access, %{"access_type" => nil})
      assert Repo.get(KeyAccess, key_access.id).access_type == key_access.access_type
    end
  end

  describe "delete_key_access!/1" do
    test "delete a key" do
      key_access = insert(:key_access)
      access_id = key_access.id

      assert %KeyAccess{id: ^access_id} = Keys.delete_key_access!(key_access)
      refute Repo.get(KeyAccess, access_id)
    end
  end

  describe "add_to_unit/2" do
    setup _ctx do
      unit = insert(:unit)
      [unit: unit]
    end

    test "adds a key to unit", %{key: %Key{id: key_id} = key, unit: %Unit{id: unit_id} = unit} do
      assert {:ok, %Key{id: ^key_id}, %Unit{id: ^unit_id}} = Keys.add_to_unit(key, unit)
      assert key_in_unit?(key, unit)
    end

    test "it's not possible to add key to same unit twice", %{key: key, unit: unit} do
      assert {:ok, _key, _unit} = Keys.add_to_unit(key, unit)
      assert {:error, :already_exists} = Keys.add_to_unit(key, unit)
      assert key_in_unit?(key, unit)
    end
  end

  describe "remove_from_unit/2" do
    setup _ctx do
      unit = insert(:unit)
      [unit: unit]
    end

    test "removes key from unit", %{key: %Key{id: key_id} = key, unit: %Unit{id: unit_id} = unit} do
      assert {:ok, %Key{id: ^key_id}, %Unit{id: ^unit_id}} = Keys.add_to_unit(key, unit)
      assert {:ok, %Key{id: ^key_id}, %Unit{id: ^unit_id}} = Keys.remove_from_unit(key, unit)
      refute key_in_unit?(key, unit)
    end

    test "returns an error when key not in unit", %{key: key, unit: unit} do
      assert {:error, :not_in_unit} = Keys.remove_from_unit(key, unit)
    end
  end

  describe "take_or_return_key/2" do
    setup _ctx do
      employee = insert(:employee)
      [employee: employee]
    end

    test "take a key when employee has access to this key", ctx do
      insert(:key_access, employee: ctx.employee, key: ctx.key, access_type: true)
      assert_key_taked(ctx.key, ctx.employee)
    end

    test "take a key when employee in same unit as a key", ctx do
      unit = insert(:unit)

      assert {1, nil} = Repo.insert_all("employee_units", [%{employee_id: ctx.employee.id, unit_id: unit.id}])
      assert {:ok, _, _} = Keys.add_to_unit(ctx.key, unit)

      assert_key_taked(ctx.key, ctx.employee)
    end

    test "do not take key when employee has no access to this key", ctx do
      unit = insert(:unit)
      insert(:key_access, employee: ctx.employee, key: ctx.key, access_type: false)

      assert {1, nil} = Repo.insert_all("employee_units", [%{employee_id: ctx.employee.id, unit_id: unit.id}])
      assert {:ok, _, _} = Keys.add_to_unit(ctx.key, unit)

      assert_key_not_taked(ctx.key, ctx.employee)
    end

    test "do not take key when there is no key access and employee not in same unit as a key", ctx do
      assert_key_not_taked(ctx.key, ctx.employee)
    end

    test "return a key", ctx do
      insert(:key_access, employee: ctx.employee, key: ctx.key, access_type: true)
      assert {:ok, %KeysJournal{id: keys_journal_id}} = Keys.take_or_return_key(ctx.key, ctx.employee)

      assert {:ok, %KeysJournal{id: ^keys_journal_id} = updated_keys_journal} =
               Keys.take_or_return_key(ctx.key, ctx.employee)

      assert updated_keys_journal.taken_by == ctx.employee.id
      assert updated_keys_journal.returned_by == ctx.employee.id
      assert updated_keys_journal.key_id == ctx.key.id
      assert Timex.diff(Timex.now(), updated_keys_journal.taken_at, :seconds) in 0..5
      assert Timex.diff(Timex.now(), updated_keys_journal.returned_at, :seconds) in 0..5
    end
  end

  describe "all_keys/0" do
    setup _ctx do
      from(k in Key) |> Repo.delete_all()
      insert_list(5, :key)
      :ok
    end

    test "returns all keys" do
      keys = Keys.all_keys()
      assert [%Key{} | _] = keys
      assert Enum.count(keys) == 5
    end
  end

  defp assert_key_taked(key, employee) do
    assert {:ok, %KeysJournal{} = created_keys_journal} = Keys.take_or_return_key(key, employee)
    assert created_keys_journal.taken_by == employee.id
    assert created_keys_journal.key_id == key.id
    assert Timex.diff(Timex.now(), created_keys_journal.taken_at, :seconds) in 0..5

    refute created_keys_journal.returned_by
    refute created_keys_journal.returned_at
  end

  defp assert_key_not_taked(key, employee) do
    assert {:error, :no_access} = Keys.take_or_return_key(key, employee)
    refute Repo.get_by(KeysJournal, key_id: key.id, taken_by: employee.id)
  end

  defp key_in_unit?(key, unit) do
    from(u in "unit_keys", where: u.unit_id == ^unit.id and u.key_id == ^key.id, select: count(u.id)) |> Repo.one!() ==
      1
  end
end
