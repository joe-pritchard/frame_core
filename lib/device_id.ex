defmodule FrameCore.DeviceId do
  use GenServer

  defmodule Config do
    @moduledoc """
    Configuration for DeviceId GenServer.
    """

    @enforce_keys [:path]
    defstruct [:path, file_system: FrameCore.FileSystem.Real]

    @type t :: %__MODULE__{
            path: String.t(),
            file_system: module()
          }
  end

  def start_link(%Config{} = config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def get, do: GenServer.call(__MODULE__, :get)

  def init(%Config{path: path, file_system: file_system}) do
    id =
      case file_system.read(path) do
        {:ok, content} ->
          String.trim(content)

        {:error, _} ->
          new_id = UUID.uuid4()
          file_system.write!(path, new_id)
          new_id
      end

    {:ok, id}
  end

  def handle_call(:get, _from, id), do: {:reply, id, id}
end
