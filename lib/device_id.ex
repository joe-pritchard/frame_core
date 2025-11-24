defmodule FrameCore.DeviceId do
  @moduledoc """
  GenServer that manages a persistent device identifier.

  Reads or generates a UUID and stores it in a file to persist across restarts.
  """

  use GenServer

  @device_id_path "device_id.txt"

  defmodule Config do
    @moduledoc """
    Configuration for DeviceId GenServer.
    """

    defstruct file_system: FrameCore.FileSystem.Real

    @type t :: %__MODULE__{
            file_system: module()
          }
  end

  @type state :: String.t()

  ## Client API

  @spec start_link(Config.t()) :: GenServer.on_start()
  def start_link(%Config{} = config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @spec get() :: String.t()
  def get, do: GenServer.call(__MODULE__, :get)

  ## Server Callbacks

  @impl GenServer
  @spec init(Config.t()) :: {:ok, state()}
  def init(%Config{file_system: file_system}) do
    id =
      case file_system.read(@device_id_path) do
        {:ok, content} ->
          String.trim(content)

        {:error, _} ->
          new_id = UUID.uuid4()
          file_system.write!(@device_id_path, new_id)
          new_id
      end

    {:ok, id}
  end

  @impl GenServer
  @spec handle_call(:get, GenServer.from(), state()) :: {:reply, String.t(), state()}
  def handle_call(:get, _from, id), do: {:reply, id, id}
end
