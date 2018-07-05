{:ok, _} = Application.ensure_all_started(:ex_machina)
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(KeyGuard.Repo, :manual)

defmodule KeyGuard.TestUtils do
  alias KeyGuard.Repo

  def generate_string(length), do: :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)

  def associate_employee_with_units(employee, units) do
    entries = Enum.map(units, &%{employee_id: employee.id, unit_id: &1.id})
    Repo.insert_all("employee_units", entries)
  end
end
