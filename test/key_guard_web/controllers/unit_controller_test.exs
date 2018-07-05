defmodule KeyGuardWeb.UnitControllerTest do
  use KeyGuardWeb.ConnCase
  alias KeyGuard.{TestUtils, Repo, Keys}
  alias KeyGuard.Units.Unit
  import KeyGuard.Factory

  describe "POST /api/v1/units" do
    setup do
      conn = insert(:user) |> auth_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      {:ok, conn: conn}
    end

    test "returns new unit after successful creating", %{conn: conn} do
      params = %{"name" => "Name"}
      conn = post(conn, unit_path(conn, :create), Poison.encode!(params))
      unit_id = Repo.get_by(Unit, name: params["name"]).id

      assert json_response(conn, 201) == %{
               "data" => %{"unit" => %{"id" => unit_id, "name" => params["name"], "parent_id" => nil}}
             }
    end

    test "when some params are invalid", %{conn: conn} do
      params = %{"name" => TestUtils.generate_string(256)} |> Poison.encode!()
      conn = post(conn, unit_path(conn, :create), params)

      assert json_response(conn, 400) == %{"error" => %{"name" => "should be at most 255 character(s)"}}
    end

    test "when user is not authenticated" do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = post(conn, unit_path(conn, :create), %{})

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "PUT /api/v1/units/:id" do
    setup do
      conn = insert(:user) |> auth_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      unit = insert(:unit)
      {:ok, conn: conn, unit: unit}
    end

    test "returns updated unit after successful updating", %{conn: conn, unit: unit} do
      params = %{"name" => "New name", "parent_id" => insert(:unit).id}
      conn = put(conn, unit_path(conn, :update, unit.id), Poison.encode!(params))

      assert json_response(conn, 200) == %{
               "data" => %{"unit" => %{"id" => unit.id, "name" => params["name"], "parent_id" => params["parent_id"]}}
             }
    end

    test "when some params are invalid", %{conn: conn, unit: unit} do
      params = %{"name" => TestUtils.generate_string(256)} |> Poison.encode!()
      conn = put(conn, unit_path(conn, :update, unit.id), params)
      assert json_response(conn, 400) == %{"error" => %{"name" => "should be at most 255 character(s)"}}
    end

    test "when unit with given ID isn't exists", %{conn: conn} do
      conn = put(conn, unit_path(conn, :update, 0), %{})
      assert json_response(conn, 404) == %{"error" => %{"message" => "Unit with given ID is not exists"}}
    end

    test "when user is not authenticated", %{unit: unit} do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = put(conn, unit_path(conn, :update, unit.id), %{})

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "DELETE /api/v1/units/:id" do
    setup do
      conn = insert(:user) |> auth_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      unit = insert(:unit)
      {:ok, conn: conn, unit: unit}
    end

    test "returns successful deletion message", %{conn: conn, unit: unit} do
      conn = delete(conn, unit_path(conn, :delete, unit.id))
      assert json_response(conn, 200) == %{"data" => %{"id" => unit.id, "message" => "Unit was successfully deleted"}}
    end

    test "when unit with given ID isn't exists", %{conn: conn} do
      conn = delete(conn, unit_path(conn, :delete, 0))
      assert json_response(conn, 404) == %{"error" => %{"message" => "Unit with given ID is not exists"}}
    end

    test "when user is not authenticated", %{unit: unit} do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = delete(conn, unit_path(conn, :delete, unit.id))

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "GET /api/v1/units" do
    setup do
      conn = insert(:user) |> auth_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      unit = insert(:unit)

      {:ok, conn: conn, unit: unit}
    end

    test "successful response", ctx do
      conn = get(ctx.conn, unit_path(ctx.conn, :index))

      assert json_response(conn, 200) == %{
               "data" => %{
                 "unit" => "root",
                 "children" => [
                   %{"type" => "unit", "id" => ctx.unit.id, "parent_id" => ctx.unit.parent_id, "name" => ctx.unit.name}
                 ],
                 "keys" => []
               }
             }
    end

    test "when user is not authenticated" do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = get(conn, unit_path(conn, :index))

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end

  describe "GET /api/v1/units/:id" do
    setup do
      conn = insert(:user) |> auth_conn() |> Plug.Conn.put_req_header("content-type", "application/json")

      unit1 = insert(:unit)
      unit2 = insert(:unit, parent_id: unit1.id)
      key = insert(:key)

      Keys.add_to_unit(key, unit1)

      {:ok, conn: conn, unit1: unit1, unit2: unit2, key: key}
    end

    test "successful response", ctx do
      conn = get(ctx.conn, unit_path(ctx.conn, :show, ctx.unit1.id))

      assert json_response(conn, 200) == %{
               "data" => %{
                 "unit" => %{
                   "type" => "unit",
                   "id" => ctx.unit1.id,
                   "name" => ctx.unit1.name,
                   "parent_id" => ctx.unit1.parent_id
                 },
                 "children" => [
                   %{
                     "type" => "unit",
                     "id" => ctx.unit2.id,
                     "name" => ctx.unit2.name,
                     "parent_id" => ctx.unit2.parent_id
                   }
                 ],
                 "keys" => [
                   %{
                     "type" => "key",
                     "id" => ctx.key.id,
                     "name" => ctx.key.name,
                     "color" => ctx.key.color,
                     "extra" => ctx.key.extra
                   }
                 ]
               }
             }
    end

    test "when unit with given ID isn't exists", %{conn: conn} do
      conn = put(conn, unit_path(conn, :show, 0), %{})
      assert json_response(conn, 404) == %{"error" => %{"message" => "Unit with given ID is not exists"}}
    end

    test "when user is not authenticated", ctx do
      conn = build_conn() |> Plug.Conn.put_req_header("content-type", "application/json")
      conn = get(conn, unit_path(conn, :show, ctx.unit1.id))

      assert json_response(conn, 401) == %{"error" => %{"message" => "Authentication error"}}
    end
  end
end
