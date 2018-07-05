defmodule KeyGuard.Staff.Employee.Validator do
  @moduledoc "Employee validation functions."

  alias KeyGuard.Staff.Employee
  import Ecto.Changeset

  @required_fields [:first_name, :last_name, :patronym, :card]
  @optional_fields [:encoded_photo]

  @spec changeset(%Employee{}, map) :: Ecto.Changeset.t()
  def changeset(employee, params \\ %{}) do
    employee
    |> cast(params, Enum.concat(@required_fields, @optional_fields))
    |> validate_required(@required_fields)
    |> validate_length(:first_name, max: 255)
    |> validate_length(:last_name, max: 255)
    |> validate_length(:patronym, max: 255)
    |> validate_length(:encoded_photo, max: 50_000)
    |> unique_constraint(:card)
  end
end
