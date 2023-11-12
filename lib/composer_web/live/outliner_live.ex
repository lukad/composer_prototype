defmodule ComposerWeb.OutlinerLive do
  alias Composer.Outliner.Item
  alias Composer.Outliner
  use ComposerWeb, :live_view

  def mount(%{"item_id" => item_id}, _session, socket) do
    items = Outliner.subtree(item_id)

    min_path_length =
      case items do
        [%Item{path: %{labels: [""]}} | _] -> 0
        [%Item{path: %{labels: labels}} | _] -> length(labels)
        [] -> 0
      end

    items_with_state = Enum.map(items, &%{item: &1, state: %{visible: true}})

    socket =
      socket
      |> stream_configure(:items_with_state, dom_id: & &1.item.id)
      |> stream(:items_with_state, items_with_state)
      |> assign(min_path_length: min_path_length)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <ul class="list-disc list-outside ml-4">
      <li
        :for={{dom_id, %{item: item, state: item_state}} <- @streams.items_with_state}
        key={dom_id}
        class={indent_class_for_item(item, @min_path_length)}
      >
        <.item item={item} item_state={item_state} />
      </li>
    </ul>
    """
  end

  def item(assigns) do
    ~H"""
    ID: <%= @item.id %> | Content: <.item_content item={@item} /> |
    <button phx-click="save" phx-value-id={@item.id}>Save</button> |
    <button phx-click="delete" phx-value-id={@item.id}>Delete</button>
    """
  end

  def item_content(%{item: %{kind: :text}} = assigns) do
    ~H"""
    <input
      type="text"
      value={@item.text}
      phx-focus="focus-content"
      phx-blur="blur-content"
      phx-value-id={@item.id}
    />
    """
  end

  def item_content(%{item: %{kind: :url}} = assigns) do
    ~H"""
    <input type="text" value={@item.url} />
    """
  end

  defp indent_class_for_item(%Item{path: %{labels: [""]}}, _min_path_length) do
    indent_class_for_depth(0)
  end

  defp indent_class_for_item(%Item{path: %{labels: labels}}, min_path_length) do
    indent_class_for_depth(length(labels) - min_path_length)
  end

  defp indent_class_for_depth(0), do: ""
  defp indent_class_for_depth(1), do: "ml-4"
  defp indent_class_for_depth(2), do: "ml-8"
  defp indent_class_for_depth(3), do: "ml-12"
  defp indent_class_for_depth(4), do: "ml-16"
  defp indent_class_for_depth(5), do: "ml-20"
  defp indent_class_for_depth(6), do: "ml-24"
  defp indent_class_for_depth(7), do: "ml-28"
  defp indent_class_for_depth(8), do: "ml-32"
  defp indent_class_for_depth(9), do: "ml-36"
  defp indent_class_for_depth(10), do: "ml-40"
  defp indent_class_for_depth(11), do: "ml-44"
  defp indent_class_for_depth(12), do: "ml-48"

  # def handle_event("save", %{"id" => id}, socket) do
  #   # TODO: access control, args are unsigned
  #   item = id |> Outliner.get_item!() |> dbg()

  #   # {field, value} =
  #   #   case dbg(item.kind) do
  #   #     :text -> {:text, socket.assigns.item.text}
  #   #     :url -> {:url, socket.assigns.item.url}
  #   #   end

  #   # {:ok, _} = Outliner.update_item(item, %{field => value})

  #   {:noreply, socket}
  # end

  # def handle_event("focus-content", %{"id" => id}, socket) do
  #   # id = String.to_integer(id)

  #   # items =
  #   #   socket.assigns.items
  #   #   |> dbg()
  #   #   |> Enum.map(fn
  #   #     {%Item{id: ^id} = item, _} = item ->
  #   #     item -> item
  #   #   end)

  #   # {:noreply, assign(socket, items: items)}
  #   {:noreply, socket}
  # end

  # def handle_event("blur-content", %{"id" => id}, socket) do
  #   # item = Enum.find(socket.assigns.items, &(&1.id == id))
  #   {:noreply, socket}
  # end
end
