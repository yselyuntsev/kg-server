defmodule KeyGuardWeb.Plug.UnauthenticatedOnly do
  @moduledoc "Plug that accepts only requests from unauthenticated users."

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts \\ []), do: if(conn.assigns[:current_user], do: error_response(conn), else: conn)

  defp error_response(conn),
    do:
      conn |> put_status(403) |> Phoenix.Controller.json(%{"error" => %{"message" => "Unauthenticated only"}}) |> halt()
end
