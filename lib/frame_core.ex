defmodule FrameCore do
  @moduledoc """
  Supervisor for `FrameCore` Will orchestrate the DeviceId, Backend, and Slideshow processes.
  """

  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end
end
