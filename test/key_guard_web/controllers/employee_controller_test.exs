defmodule KeyGuardWeb.EmployeeControllerTest do
  use KeyGuardWeb.ConnCase
  alias KeyGuard.Repo
  alias KeyGuard.Staff.Employee
  import KeyGuard.Factory

  @encoded_photo "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg=="

  setup do
    [unit1, unit2] = insert_pair(:unit)
    employee = insert(:employee)
    conn = insert(:user) |> auth_conn() |> Plug.Conn.put_req_header("content-type", "application/json")

    {:ok, unit1: unit1, unit2: unit2, employee: employee, conn: conn}
  end

  describe "GET /api/v1/employees" do
    test "successful response", ctx do
      employee = Repo.get(Employee, ctx.employee.id) |> Repo.preload(:units)
      conn = get(ctx.conn, employee_path(ctx.conn, :index))

      assert json_response(conn, 200) == %{
               "data" => %{
                 "employees" => [%{
                   "id" => employee.id,
                   "first_name" => employee.first_name,
                   "last_name" => employee.last_name,
                   "patronym" => employee.patronym,
                   "card" => employee.card,
                   "encoded_photo" => employee.encoded_photo,
                   "unit_ids" => Enum.map(employee.units, fn(unit) -> unit.id end)
                 }]
               }
             }
    end

    test "when user is not authenticated" do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = get(conn, employee_path(conn, :index))

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "POST /api/v1/employees" do
    test "returns new employee after successful creating", ctx do
      params = %{
        "first_name" => "Bruce",
        "last_name" => "Wayne",
        "patronym" => "Batman",
        "card" => "super-unique-card-number",
        "encoded_photo" => @encoded_photo,
        "unit_ids" => [ctx.unit1.id, ctx.unit2.id]
      }

      conn = post(ctx.conn, employee_path(ctx.conn, :create), Poison.encode!(params))
      employee_id = Repo.get_by(Employee, card: params["card"]).id

      assert json_response(conn, 201) == %{
               "data" => %{
                 "employee" => %{
                   "id" => employee_id,
                   "first_name" => params["first_name"],
                   "last_name" => params["last_name"],
                   "patronym" => params["patronym"],
                   "card" => params["card"],
                   "encoded_photo" => params["encoded_photo"]
                 }
               }
             }
    end

    test "when some params are invalid", ctx do
      params = %{
        "first_name" => nil,
        "last_name" => "Wayne",
        "patronym" => "Batman",
        "card" => "super-unique-card-number",
        "encoded_photo" => @encoded_photo,
        "unit_ids" => [ctx.unit1.id, ctx.unit2.id]
      }

      conn = post(ctx.conn, employee_path(ctx.conn, :create), params)

      assert json_response(conn, 400) == %{"error" => %{"first_name" => "can't be blank"}}
    end

    test "when user is not authenticated" do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = post(conn, employee_path(conn, :create), %{})

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "PUT /api/v1/employees/:id" do
    test "returns updated employee after successful updating", ctx do
      params = %{
        "first_name" => "Peter",
        "last_name" => "Parker",
        "patronym" => "Spiderman",
        "encoded_photo" => @encoded_photo,
        "unit_ids" => [ctx.unit1.id]
      }

      
      conn = put(ctx.conn, employee_path(ctx.conn, :update, ctx.employee.id), Poison.encode!(params))

      assert json_response(conn, 200) == %{
               "data" => %{
                 "employee" => %{
                   "id" => ctx.employee.id,
                   "first_name" => params["first_name"],
                   "last_name" => params["last_name"],
                   "patronym" => params["patronym"],
                   "card" => ctx.employee.card,
                   "encoded_photo" => params["encoded_photo"]
                 }
               }
             }
    end

    test "when some params are invalid", ctx do
      params = %{
        "first_name" => nil,
        "last_name" => "Wayne",
        "patronym" => "Batman",
        "card" => "super-unique-card-number",
        "encoded_photo" => @encoded_photo,
        "unit_ids" => [ctx.unit1.id, ctx.unit2.id]
      }

      conn = put(ctx.conn, employee_path(ctx.conn, :update, ctx.employee.id), Poison.encode!(params))
      assert json_response(conn, 400) == %{"error" => %{"first_name" => "can't be blank"}}
    end

    test "when employee with given ID isn't exists", %{conn: conn} do
      conn = put(conn, employee_path(conn, :update, 0), %{})
      assert json_response(conn, 404) == %{"error" => %{"message" => "Employee with given ID is not exists"}}
    end

    test "when user is not authenticated", %{employee: employee} do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = put(conn, employee_path(conn, :update, employee.id), %{})

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "DELETE /api/v1/employees/:id" do
    test "returns successful deletion message", %{conn: conn, employee: employee} do
      conn = delete(conn, employee_path(conn, :delete, employee.id))

      assert json_response(conn, 200) == %{
               "data" => %{"id" => employee.id, "message" => "Employee was successfully deleted"}
             }
    end

    test "when employee with given ID isn't exists", %{conn: conn} do
      conn = delete(conn, employee_path(conn, :delete, 0))
      assert json_response(conn, 404) == %{"error" => %{"message" => "Employee with given ID is not exists"}}
    end

    test "when user is not authenticated", %{employee: employee} do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = delete(conn, employee_path(conn, :delete, employee.id))

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "GET /api/v1/employees/:card_number" do
    test "returns successful response", ctx do
      employee = Repo.get(Employee, ctx.employee.id) |> Repo.preload(:units)
      conn = get(ctx.conn, employee_path(ctx.conn, :find_by_card_number, ctx.employee.card))

      assert json_response(conn, 200) == %{
               "data" => %{
                 "employee" => %{
                   "id" => ctx.employee.id,
                   "first_name" => ctx.employee.first_name,
                   "last_name" => ctx.employee.last_name,
                   "patronym" => ctx.employee.patronym,
                   "card" => ctx.employee.card,
                   "encoded_photo" => ctx.employee.encoded_photo,
                   "unit_ids" => Enum.map(employee.units, fn(unit) -> unit.id end)
                 }
               }
             }
    end

    test "when employee with given card number isn't exists", ctx do
      conn = get(ctx.conn, employee_path(ctx.conn, :find_by_card_number, "fake"))
      assert json_response(conn, 404) == %{"error" => %{"message" => "Employee with given card number is not exists"}}
    end

    test "when user is not authenticated", %{employee: employee} do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = get(conn, employee_path(conn, :find_by_card_number, employee.card))

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end
end
