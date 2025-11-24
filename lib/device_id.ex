defmodule FrameCore.DeviceId do
  use GenServer

  @path "device_id.txt"

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get, do: GenServer.call(__MODULE__, :get)

  def init(_) do
    id =
      case File.read(@path) do
        {:ok, content} ->
          String.trim(content)

        {:error, _} ->
          new_id = UUID.uuid4()
          File.write!(@path, new_id)
          new_id
      end

    {:ok, id}
  end

  def handle_call(:get, _from, id), do: {:reply, id, id}
end
