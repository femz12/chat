defmodule ChatWeb.RoomLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    username = MnemonicSlugs.generate_slug(2)

    if connected?(socket), do: ChatWeb.Endpoint.subscribe(topic)

    {:ok,
     assign(socket,
       room_id: room_id,
       topic: topic,
       message: "",
       username: username,
       messages: [
         %{uuid: UUID.uuid4(), content: "Howdy!", username: "system"},
         %{uuid: UUID.uuid4(), content: "I miss you", username: "system"}
       ],
       temporary_assign: [messages: []]
     )}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message)

    ChatWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", [
      %{uuid: UUID.uuid4(), content: message, username: socket.assigns.username}
    ])

    {:noreply, assign(socket, message: "")}
  end

  def handle_event("form_update", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message: message)
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    {:noreply, assign(socket, messages: message)}
  end
end
