defmodule KeyGuard.Units do
  @moduledoc "Units context functions."

  alias KeyGuard.Repo
  alias KeyGuard.Units.Unit
  alias KeyGuard.Units.Unit.Validator, as: UnitValidator
  import Ecto.Query, only: [from: 2]

  @doc "Finds an unit by given ID or returns nil when key isn't exits."
  @spec find_unit(non_neg_integer) :: %Unit{} | nil
  def find_unit(unit_id), do: Repo.get(Unit, unit_id)

  @doc """
  Creates an unit.
  The function takes `params` arg and returns one of:
    * `{:ok, unit}` - when unit was successfully created;
    * `{:error, changeset}` - when some params are invalid.

  `params` map have to include `name` field and optionally `parent_id`, where `parent_id` is parent unit's id.
  When you wan to create a root unit (unit without parent), just skip `parent_id` param.

  ### Example:
      unit = Repo.get(Unit, id)
      params = %{"name" => "Unit name", "parent_id" => unit.id}
      Units.create_unit(params) # => {:ok, created_unit}
  """
  @spec create_unit(map) :: {:ok, %Unit{}} | {:error, %Ecto.Changeset{}}
  def create_unit(params), do: %Unit{} |> UnitValidator.changeset(params) |> Repo.insert()

  @doc """
  Updates an unit.
  The function takes `unit` and `params` arg and returns one of:
    * `{:ok, unit}` - when unit was successfully updated;
    * `{:error, changeset}` - when some params are invalid.

  ### Example:
      unit1 = Repo.get(Unit, id)
      unit2 = Repo.get(Unit, id2)
      params = %{"name" => "Unit name", "parent_id" => unit2.id}
      Units.update_unit(params) # => {:ok, updated_unit}
  """
  @spec update_unit(%Unit{}, map) :: {:ok, %Unit{}} | {:error, %Ecto.Changeset{}}
  def update_unit(unit, params), do: unit |> UnitValidator.changeset(params) |> Repo.update()

  @doc "Deletes an unit. Note that all child units will be deleted too."
  @spec delete_unit!(%Unit{}) :: %Unit{} | no_return
  def delete_unit!(unit), do: Repo.delete!(unit)

  @doc """
  Returns unit, children units and associated key.
  The function takes `unit` param and returns a map with `:unit`, `:children` and `:keys` keys.
  If `unit` params is nil or not provided, then only root units (units wihout parent_id) will be returned.

  ### Example:
      Units.show_unit() # => %{unit: "root", children: [..], keys: [..]}
      Units.show_unit(unit) # => %{unit: %Unit{..}, children: [..], keys: [..]}
  """
  @spec show_unit(%Unit{} | nil) :: map
  def show_unit(unit \\ nil)

  def show_unit(nil) do
    children = from(u in Unit, where: is_nil(u.parent_id)) |> Repo.all()
    %{unit: "root", children: children, keys: []}
  end

  def show_unit(%Unit{} = unit) do
    children = from(u in Unit, where: u.parent_id == ^unit.id) |> Repo.all()
    keys = Repo.preload(unit, :keys).keys

    %{unit: unit, children: children, keys: keys}
  end
end
