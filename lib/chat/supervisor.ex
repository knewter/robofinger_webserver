defmodule Chat.Supervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    {:ok, client} = Exroboarm.Client.start("/dev/ttyUSB0")
    Process.register client, :roboarm
    children = [
      # Define workers and child supervisors to be supervised
      # worker(Chat.Router, [])
    ]

    # See http://elixir-lang.org/docs/stable/Supervisor.Behaviour.html
    # for other strategies and supported options
    supervise(children, strategy: :one_for_one)
  end
end
