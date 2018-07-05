defmodule KeyGuardWeb.KeysControllerTest do
  use KeyGuardWeb.ConnCase
  alias KeyGuard.{TestUtils, Keys}
  import KeyGuard.Factory

  setup do
    conn = insert(:user) |> auth_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
    key = insert(:key)
    employee = insert(:employee)
    unit = insert(:unit)

    {:ok, conn: conn, key: key, employee: employee, unit: unit}
  end

  describe "GET /api/v1/keys" do
    test "successful response", ctx do
      conn = get(ctx.conn, key_path(ctx.conn, :index))

      assert json_response(conn, 200) == %{
               "data" => %{
                 "keys" => [
                   %{"id" => ctx.key.id, "name" => ctx.key.name, "color" => ctx.key.color, "extra" => ctx.key.extra}
                 ]
               }
             }
    end

    test "when user is not authenticated" do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = get(conn, key_path(conn, :index))

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "GET /api/v1/keys/taken/:employee_id" do
    test "successful responce", ctx do
      conn = get(ctx.conn, key_path(ctx.conn, :employee_taken_keys, ctx.employee.id))
      assert json_response(conn, 200) == %{"data" => %{"keys" => []}}
    end
  end

  describe "GET /api/v1/keys/:id" do
    test "successful responce", ctx do
      conn = get(ctx.conn, key_path(ctx.conn, :show, ctx.key.id))

      assert json_response(conn, 200) == %{
        "data" => %{
          "key" => %{
            "id" => ctx.key.id,
            "name" => ctx.key.name,
            "color" => ctx.key.color,
            "extra" => ctx.key.extra
          }
        }
      }
    end
  end

  describe "POST /api/v1/keys" do
    test "returns new key after successful creating", %{conn: conn} do
      params = %{
        "id" => "some-key-id",
        "name" => "Key for all doors",
        "color" => "gold",
        "extra" => "Use it to open any door that you want"
      }

      conn = post(conn, key_path(conn, :create), Poison.encode!(params))

      assert json_response(conn, 201) == %{
               "data" => %{
                 "key" => %{
                   "id" => params["id"],
                   "name" => params["name"],
                   "color" => params["color"],
                   "extra" => params["extra"]
                 }
               }
             }
    end

    test "when some params are invalid", %{conn: conn} do
      params = %{"name" => TestUtils.generate_string(256)} |> Poison.encode!()
      conn = post(conn, key_path(conn, :create), params)

      assert json_response(conn, 400) == %{
               "error" => %{
                 "name" => "should be at most 50 character(s)",
                 "id" => "can't be blank",
                 "color" => "can't be blank"
               }
             }
    end

    test "when user is not authenticated" do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = post(conn, key_path(conn, :create), %{})

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "PUT /api/v1/keys/:id" do
    test "returns updated key after successful updating", %{conn: conn, key: key} do
      params = %{
        "name" => "Key for all doors",
        "color" => "blue",
        "extra" => "Use it to open any door that you want"
      }

      conn = put(conn, key_path(conn, :update, key.id), Poison.encode!(params))

      assert json_response(conn, 200) == %{
               "data" => %{
                 "key" => %{
                   "id" => key.id,
                   "name" => params["name"],
                   "color" => params["color"],
                   "extra" => params["extra"]
                 }
               }
             }
    end

    test "when some params are invalid", %{conn: conn, key: key} do
      params = %{"name" => TestUtils.generate_string(256)} |> Poison.encode!()
      conn = put(conn, key_path(conn, :update, key.id), params)
      assert json_response(conn, 400) == %{"error" => %{"name" => "should be at most 50 character(s)"}}
    end

    test "when key with given ID isn't exists", %{conn: conn} do
      conn = put(conn, key_path(conn, :update, "fake-id"), %{})
      assert json_response(conn, 404) == %{"error" => %{"message" => "Key with given ID is not exists"}}
    end

    test "when user is not authenticated", %{key: key} do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = put(conn, key_path(conn, :update, key.id), %{})

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "DELETE /api/v1/keys/:id" do
    test "returns successful deletion message", %{conn: conn, key: key} do
      conn = delete(conn, key_path(conn, :delete, key.id))
      assert json_response(conn, 200) == %{"data" => %{"id" => key.id, "message" => "Key was successfully deleted"}}
    end

    test "when key with given ID isn't exists", %{conn: conn} do
      conn = delete(conn, key_path(conn, :delete, "fake-id"))
      assert json_response(conn, 404) == %{"error" => %{"message" => "Key with given ID is not exists"}}
    end

    test "when user is not authenticated", %{key: key} do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = delete(conn, key_path(conn, :delete, key.id))

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "POST /api/v1/keys/:key_id/unit/:unit_id" do
    test "returns successful message", %{conn: conn, key: key, unit: unit} do
      conn = post(conn, key_path(conn, :add_to_unit, key.id, unit.id))
      assert json_response(conn, 200) == %{"data" => %{"key_id" => key.id, "unit_id" => unit.id}}
    end

    test "when key is already on unit", %{conn: conn, key: key, unit: unit} do
      # Add key to unit
      assert {:ok, _key, _unit} = Keys.add_to_unit(key, unit)

      conn = post(conn, key_path(conn, :add_to_unit, key.id, unit.id))
      assert json_response(conn, 409) == %{"error" => %{"message" => "Key is already in unit"}}
    end

    test "when key with given ID isn't exists", %{conn: conn, unit: unit} do
      conn = post(conn, key_path(conn, :add_to_unit, "fake-id", unit.id))
      assert json_response(conn, 404) == %{"error" => %{"message" => "Key with given ID is not exists"}}
    end

    test "when unit with given ID isn't exists", %{conn: conn, key: key} do
      conn = post(conn, key_path(conn, :add_to_unit, key.id, 0))
      assert json_response(conn, 404) == %{"error" => %{"message" => "Unit with given ID is not exists"}}
    end

    test "when user is not authenticated", %{key: key, unit: unit} do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = post(conn, key_path(conn, :add_to_unit, key.id, unit.id))

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "DELETE /api/v1/keys/:key_id/unit/:unit_id" do
    test "returns successful message", %{conn: conn, key: key, unit: unit} do
      # Add key to unit
      assert {:ok, _key, _unit} = Keys.add_to_unit(key, unit)

      conn = delete(conn, key_path(conn, :remove_from_unit, key.id, unit.id))

      assert json_response(conn, 200) == %{
               "data" => %{
                 "key_id" => key.id,
                 "unit_id" => unit.id,
                 "message" => "Key was successfully removed from unit"
               }
             }
    end

    test "when key is not in unit", %{conn: conn, key: key, unit: unit} do
      conn = delete(conn, key_path(conn, :remove_from_unit, key.id, unit.id))
      assert json_response(conn, 404) == %{"error" => %{"message" => "Key isn't in unit"}}
    end

    test "when key with given ID isn't exists", %{conn: conn, unit: unit} do
      conn = delete(conn, key_path(conn, :remove_from_unit, "fake-id", unit.id))
      assert json_response(conn, 404) == %{"error" => %{"message" => "Key with given ID is not exists"}}
    end

    test "when unit with given ID isn't exists", %{conn: conn, key: key} do
      conn = delete(conn, key_path(conn, :remove_from_unit, key.id, 0))
      assert json_response(conn, 404) == %{"error" => %{"message" => "Unit with given ID is not exists"}}
    end

    test "when user is not authenticated", %{key: key, unit: unit} do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = delete(conn, key_path(conn, :remove_from_unit, key.id, unit.id))

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "POST /api/v1/keys/:key_id/take-or-return/:employee_id" do
    setup _ctx do
      employee = insert(:employee)
      [employee: employee]
    end

    test "returns successful response when key was taken", ctx do
      insert(:key_access, key: ctx.key, employee: ctx.employee, access_type: true)
      conn = post(ctx.conn, key_path(ctx.conn, :take_or_return, ctx.key.id, ctx.employee.id))

      assert json_response(conn, 200) == %{
               "data" => %{"key_id" => ctx.key.id, "employee_id" => ctx.employee.id, "action" => "take"}
             }
    end

    test "returns successful response when key was returned", ctx do
      insert(:key_access, key: ctx.key, employee: ctx.employee, access_type: true)
      assert {:ok, _} = Keys.take_or_return_key(ctx.key, ctx.employee)

      conn = post(ctx.conn, key_path(ctx.conn, :take_or_return, ctx.key.id, ctx.employee.id))

      assert json_response(conn, 200) == %{
               "data" => %{"key_id" => ctx.key.id, "employee_id" => ctx.employee.id, "action" => "return"}
             }
    end

    test "returns error response when employee has no access to take this key", ctx do
      conn = post(ctx.conn, key_path(ctx.conn, :take_or_return, ctx.key.id, ctx.employee.id))

      assert json_response(conn, 400) == %{"error" => %{"message" => "Employee has no access to take this key"}}
    end

    test "when key with given ID isn't exists", ctx do
      conn = post(ctx.conn, key_path(ctx.conn, :take_or_return, "fake-id", ctx.employee.id))
      assert json_response(conn, 404) == %{"error" => %{"message" => "Key with given ID is not exists"}}
    end

    test "when employee with given ID isn't exists", ctx do
      conn = post(ctx.conn, key_path(ctx.conn, :take_or_return, ctx.key.id, 0))
      assert json_response(conn, 404) == %{"error" => %{"message" => "Employee with given ID is not exists"}}
    end

    test "when user is not authenticated", ctx do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = post(conn, key_path(conn, :take_or_return, ctx.key.id, ctx.employee.id))

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end
end
