defmodule KeyGuard.UnitsTest do
  use KeyGuard.DataCase
  alias KeyGuard.{Units, Repo, Keys}
  alias KeyGuard.Units.Unit
  import KeyGuard.Factory

  describe "find_unit/1" do
    test "finds an unit by given id" do
      unit_id = insert(:unit).id
      assert %Unit{id: ^unit_id} = Units.find_unit(unit_id)
    end

    test "returns nil when unit with given id isn't exists" do
      assert Units.find_unit(0) == nil
    end
  end

  describe "create_unit/1" do
    test "with valid params (without parent_id)" do
      params = %{"name" => "Unit name"}

      assert {:ok, %Unit{} = unit} = Units.create_unit(params)
      assert unit.name == params["name"]
      assert unit.parent_id == nil
    end

    test "with valid params (with parent_id)" do
      params = %{"name" => "Unit name", "parent_id" => insert(:unit).id}

      assert {:ok, %Unit{} = unit} = Units.create_unit(params)
      assert unit.name == params["name"]
      assert unit.parent_id == params["parent_id"]
    end

    test "with invalid params" do
      assert {:error, %Ecto.Changeset{}} = Units.create_unit(%{})
      assert [] = Repo.all(Unit)
    end

    test "when parent is not exists" do
      assert {:error, %Ecto.Changeset{}} = Units.create_unit(%{"name" => "Unit name", "parent_id" => -1})
      assert [] = Repo.all(Unit)
    end
  end

  describe "update_unit/2" do
    setup do
      [unit1, unit2] = insert_pair(:unit)
      {:ok, unit1: unit1, unit2: unit2}
    end

    test "with valid params", ctx do
      params = %{"name" => "New unit name", "parent_id" => ctx.unit2.id}

      assert {:ok, %Unit{} = updated_unit} = Units.update_unit(ctx.unit1, params)
      assert updated_unit.name == params["name"]
      assert updated_unit.parent_id == params["parent_id"]
    end

    test "with invalid params", ctx do
      assert {:error, %Ecto.Changeset{}} = Units.update_unit(ctx.unit1, %{"name" => nil})
      unit = Repo.get(Unit, ctx.unit1.id)
      assert unit.name == ctx.unit1.name
    end

    test "when parent is not exists", ctx do
      assert {:error, %Ecto.Changeset{}} = Units.update_unit(ctx.unit1, %{"name" => "Unit name", "parent_id" => -1})
      unit = Repo.get(Unit, ctx.unit1.id)
      assert unit.name == ctx.unit1.name
      assert unit.parent_id == ctx.unit1.parent_id
    end
  end

  describe "delete_unit!/1" do
    test "delete an unit" do
      unit = insert(:unit)
      unit_id = unit.id

      insert(:unit, parent_id: unit_id)

      assert %Unit{id: ^unit_id} = Units.delete_unit!(unit)
      # Child units will be deleted too
      assert [] = Repo.all(Unit)
    end
  end

  describe "show_unit/1" do
    setup do
      [unit1, unit2] = insert_pair(:unit)
      [key1, key2] = insert_pair(:key)
      unit3 = insert(:unit, parent_id: unit2.id)

      Keys.add_to_unit(key1, unit2)
      Keys.add_to_unit(key2, unit2)

      {:ok, unit1: unit1, unit2: unit2, unit3: unit3, key1: key1, key2: key2}
    end

    test "returns only root units (without parent_id) when parent_id isn't provided", ctx do
      assert %{unit: "root", children: children, keys: []} = Units.show_unit()
      assert Enum.count(children) == 2
      assert ctx.unit1 in children
      assert ctx.unit2 in children
    end

    test "returns unit's children and associated keys", %{unit2: unit2, unit3: unit3} = ctx do
      assert %{unit: ^unit2, children: [^unit3], keys: keys} = Units.show_unit(unit2)
      assert Enum.count(keys) == 2
      assert ctx.key1 in keys
      assert ctx.key2 in keys
    end
  end
end
