defmodule Chat.Channels.Rooms do
  use Phoenix.Channel

  @doc """
  Authorize socket to subscribe and broadcast events on this channel & topic

  Possible Return Values

  {:ok, socket} to authorize subscription for channel for requested topic

  {:error, socket, reason} to deny subscription/broadcast on this channel
  for the requested topic
  """
  def join(socket, "lobby", message) do
    IO.puts "JOIN #{socket.channel}:#{socket.topic}"
    reply socket, "join", status: "connected"
    broadcast socket, "user:entered", username: message["username"]
    {:ok, socket}
  end

  def join(socket, _private_topic, _message) do
    {:error, socket, :unauthorized}
  end

  def event(socket, "new:message", message) do
    broadcast socket, "new:message", message
    socket
  end
  def event(socket, "position:finger", message) do
    handle_message(message["body"])
    socket
  end
  def event(socket, "rotation:hand", %{"x" => x, "y" => y, "z" => z}) do
    val = map(x, 0, 180, -1, 1)
    Exroboarm.Client.hip(:roboarm, val, 10)
    socket
  end
  def event(socket, "bone_directions:index_finger", %{"first" => first, "second" => second, "third" => third}) do
    IO.puts "first: #{inspect first}, second: #{inspect second}, third: #{inspect third}"

    Exroboarm.Client.shoulder(:roboarm, first + 90, 10)
    Exroboarm.Client.elbow(:roboarm, second, 10)
    Exroboarm.Client.wrist(:roboarm, (90 - third), 10)

    socket
  end
  def event(socket, other, message) do
    IO.puts "other: #{other}, #{inspect message}"
    socket
  end

  defp handle_message("u") do
    Exroboarm.Client.shoulder(:roboarm, 90, 10)
  end
  defp handle_message("d") do
    Exroboarm.Client.shoulder(:roboarm, 0, 10)
  end
  defp handle_rotation(x, _, _) do
  end

  defp handle_message(message) do
    IO.puts message
    IO.puts "zomg no clue"
  end

  defp map(value, to_min, to_max, from_min, from_max) do
    distance_from_from_min = value - from_min
    distance_total = from_max - from_min
    distance_percentage = distance_from_from_min/distance_total
    distance_percentage = cond do
      distance_percentage > 1 -> 1
      distance_percentage < 0 -> 0
      true -> distance_percentage
    end
    mapped = to_min + (distance_percentage * (to_max - to_min))
  end
end
