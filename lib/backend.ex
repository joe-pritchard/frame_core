defmodule FrameCore.Backend do
  @moduledoc """
  GenServer that fetches image data from a remote backend server.
  """
  use GenServer

  require Logger

  @default_client Application.compile_env(:frame_core, :http_client, FrameCore.HttpClient.Real)

  defmodule Config do
    @moduledoc """
    Configuration for Backend GenServer.
    """

    @enforce_keys [:device_id]
    defstruct [:device_id, client: nil, backend_url: nil]

    @type t :: %__MODULE__{
            device_id: String.t(),
            client: module(),
            backend_url: String.t() | nil
          }
  end

  defmodule State do
    @moduledoc false
    @type t :: %__MODULE__{
            device_id: String.t(),
            client: module(),
            backend_url: String.t()
          }
    defstruct device_id: nil, client: nil, backend_url: nil
  end

  ## Client API

  @spec start_link(Config.t()) :: GenServer.on_start()
  def start_link(%Config{} = config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @doc """
  Fetches images from the backend, optionally filtering by last update time.
  """
  @spec fetch_images(DateTime.t() | nil) :: {:ok, list()} | {:error, term()}
  def fetch_images(last_fetch \\ nil) do
    GenServer.call(__MODULE__, {:fetch_images, last_fetch})
  end

  ## Server Callbacks

  @impl true
  @spec init(Config.t()) :: {:ok, State.t()}
  def init(%Config{device_id: device_id, client: client, backend_url: backend_url}) do
    actual_client = client || @default_client
    actual_url = backend_url || System.fetch_env!("BACKEND_URL")

    state = %State{
      device_id: device_id,
      client: actual_client,
      backend_url: actual_url
    }

    {:ok, state}
  end

  @impl true
  @spec handle_call(
          {:fetch_images, DateTime.t() | nil},
          GenServer.from(),
          State.t()
        ) ::
          {:reply, {:ok, list()} | {:error, term()}, State.t()}
  def handle_call({:fetch_images, last_fetch}, _from, %State{} = state) do
    params = build_params(last_fetch)
    headers = build_headers(state.device_id)
    url = "#{state.backend_url}/images"

    case state.client.get_json(url, params, headers) do
      {:ok, response} ->
        images = parse_images_response(response)
        {:reply, {:ok, images}, state}

      {:error, reason} = error ->
        Logger.error("Failed to fetch images: #{inspect(reason)}")
        {:reply, error, state}
    end
  end

  ## Private Functions

  defp build_params(nil), do: %{}

  defp build_params(%DateTime{} = last_fetch) do
    %{"since" => DateTime.to_iso8601(last_fetch)}
  end

  defp build_headers(device_id) do
    [
      {"Content-Type", "application/json"},
      {"X-Device-ID", device_id}
    ]
  end

  defp parse_images_response(%{"images" => images}) when is_list(images), do: images
  defp parse_images_response(_), do: []
end
