defmodule KeyGuard.Staff do
  @moduledoc "Staff context functions."

  alias KeyGuard.Repo
  alias KeyGuard.Staff.Employee
  alias KeyGuard.Staff.Employee.Validator, as: EmployeeValidator
  alias KeyGuard.Units.Unit
  import Ecto.Query

  @doc "Returns all employees."
  @spec all_employees() :: [%Employee{}]
  def all_employees(), do: Repo.all(Employee) |> Repo.preload(:units)

  @doc "Finds an employee by given ID or returns nil when employee isn't exits."
  @spec find_employee(non_neg_integer) :: %Employee{} | nil
  def find_employee(employee_id), do: Repo.get(Employee, employee_id) |> Repo.preload(:units)

  @doc "Finds an employee by given card number or returns nil when employee isn't exits."
  @spec find_employee_by_card_number(String.t()) :: %Employee{} | nil
  def find_employee_by_card_number(card_number), do: Repo.get_by(Employee, card: card_number) |> Repo.preload(:units)

  @doc """
  Creates an employee.
  The function takes `params` arg and returns one of:
    * `{:ok, employee}` - when employee was successfully created;
    * `{:error, changeset}` - when params are invalid.

  `unit_ids` field in `params` map should contents ids of units which employee will associated with.

  ### Example:
      unit = Repo.get(Unit, id)
      params = %{
        "first_name" => "..",
        "last_name" => "..",
        "patronym" => "..",
        "card" => "..",
        "encoded_photo" => "not required",
        "unit_ids" => [unit.id]
      }

      Staff.create_employee(params)
  """
  @spec create_employee(map) :: {:ok, %Employee{}} | {:error, Ecto.Changeset.t()}
  def create_employee(params) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:employee, EmployeeValidator.changeset(%Employee{}, params))
      |> associate_employee_with_units(params["unit_ids"])

    case Repo.transaction(multi) do
      {:ok, %{employee: employee}} -> {:ok, employee}
      {:error, :employee, changeset, _} -> {:error, changeset}
      error -> error
    end
  end

  @doc """
  Updates an employee.
  The function takes `params` arg and returns one of:
    * `{:ok, employee}` - when employee was successfully updated;
    * `{:error, changeset}` - when params are invalid.

  `unit_ids` field in `params` map should contents ids of units which employee will associated with.
  Note that old associations will be removed after updation, so if you want to associate an employee with some new unit
  and save old associations, then you should provide all ids of old associated units.

  ### Example:
      employee = Repo.get(Employee, employee_id)
      unit = Repo.get(Unit, unit_id)
      params = %{
        "first_name" => "..",
        "last_name" => "..",
        "patronym" => "..",
        "card" => "..",
        "encoded_photo" => "not required",
        "unit_ids" => [unit.id]
      }

      Staff.update_employee(employee, params)
  """
  @spec update_employee(%Employee{}, map) :: {:ok, %Employee{}} | {:error, Ecto.Changeset.t()}
  def update_employee(employee, params) do
    delete_query = from(e in "employee_units", where: e.employee_id == ^employee.id)

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:employee, EmployeeValidator.changeset(employee, params))
      |> Ecto.Multi.delete_all(:old_employee_units, delete_query)
      |> associate_employee_with_units(params["unit_ids"])

    case Repo.transaction(multi) do
      {:ok, %{employee: updated_employee}} -> {:ok, updated_employee}
      {:error, :employee, changeset, _} -> {:error, changeset}
      error -> error
    end
  end

  @doc "Deletes an employee."
  @spec delete_employee!(%Employee{}) :: %Employee{} | no_return
  def delete_employee!(employee), do: Repo.delete!(employee)

  defp associate_employee_with_units(multi, unit_ids) when unit_ids in [[], nil], do: multi

  defp associate_employee_with_units(multi, unit_ids) do
    multi
    |> Ecto.Multi.run(:employee_units, fn %{employee: employee} ->
      entries =
        from(u in Unit, where: u.id in ^unit_ids, select: u.id)
        |> Repo.all()
        |> Enum.map(&%{employee_id: employee.id, unit_id: &1})

      {count, _} = Repo.insert_all("employee_units", entries)
      {:ok, count}
    end)
  end
end
