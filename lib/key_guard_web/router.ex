defmodule KeyGuardWeb.Router do
  use KeyGuardWeb, :router
  alias KeyGuardWeb.Plug.{Authenticate, UnauthenticatedOnly}

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Routes that available only for unauthenticated users
  scope "/api/v1", KeyGuardWeb do
    pipe_through [:api, UnauthenticatedOnly]

    post "/admin/users/authenticate", UserController, :authenticate
  end

  # Routes that available only for authenticated users
  scope "/api/v1", KeyGuardWeb do
    pipe_through [:api, Authenticate]

    post "/admin/users", UserController, :create

    get "/status", UserController, :status

    get "/keys", KeyController, :index
    post "/keys", KeyController, :create
    put "/keys/:id", KeyController, :update
    delete "/keys/:id", KeyController, :delete
    get "/keys/taken", KeyController, :all_taken_keys
    get "/keys/:id", KeyController, :show
    get "/keys/taken/:employee_id", KeyController, :employee_taken_keys
    post "/keys/:key_id/unit/:unit_id", KeyController, :add_to_unit
    delete "/keys/:key_id/unit/:unit_id", KeyController, :remove_from_unit
    post "/keys/:key_id/take-or-return/:employee_id", KeyController, :take_or_return

    get "/key-access", KeyAccessController, :index
    post "/key-access", KeyAccessController, :create
    get "/key-access/:employee_id", KeyAccessController, :show
    put "/key-access/:id", KeyAccessController, :update
    delete "/key-access/:id", KeyAccessController, :delete

    get "/employees", EmployeeController, :index
    post "/employees", EmployeeController, :create
    put "/employees/:id", EmployeeController, :update
    delete "/employees/:id", EmployeeController, :delete
    get "/employees/:card_number", EmployeeController, :find_by_card_number

    post "/units", UnitController, :create
    put "/units/:id", UnitController, :update
    delete "/units/:id", UnitController, :delete
    get "/units", UnitController, :index
    get "/units/:id", UnitController, :show
  end
end
