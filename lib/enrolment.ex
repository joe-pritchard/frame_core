defmodule Frame.Enrolment do
  @moduledoc """
  GenServer for managing enrolment operations.
  """

  use GenServer

  require Logger

  defmodule State do
    @moduledoc false
    @type t :: %__MODULE__{
            enrolled: boolean()
          }
    defstruct enrolled: false
  end

  # Client API

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def check_enrolment() do
    GenServer.call(__MODULE__, :check_enrolment)
  end

  # Server Callbacks

  @impl GenServer
  def handle_call(:check_enrolment, _from, state) do
    case FrameCore.Backend.authenticate_device() do
      {:ok, _response} ->
        Logger.info("Device successfully enrolled.")

        {:reply, true, %State{enrolled: true}}

      {:error, {:http_error, status}} when status in 400..499 ->
        Logger.error(
          "Device enrolment failed with client error status #{status}. Setting enrolled to false."
        )

        {:reply, false, %State{enrolled: false}}

      {:error, {:http_error, status}} when status in 500..599 ->
        Logger.error("Failed to check enrolment with server error status #{status}.")

        {:reply, state.enrolled, state}

      {:error, reason} ->
        Logger.warning("Unable to check enrolment: #{inspect(reason)}")

        {:reply, state.enrolled, state}
    end
  end
end
