defmodule ComposerWeb.TreeOutlinerLive do
  alias Composer.Outliner
  use ComposerWeb, :live_view

  def mount(%{"item_id" => item_id}, _session, socket) do
    items = Outliner.subtree(item_id)
    tree = Outliner.arrange(items)

    socket = assign(socket, items: items, tree: tree)
    {:ok, socket, temporary_assigns: [tree: []]}
  end

  # def mount(_params, _session, socket) do
  #   children = Outliner.descendants(nil) |> Outliner.arrange(nil)
  #   {:ok, assign(socket, :root, nil) |> assign(:children, children)}
  # end

  def render(assigns) do
    ~H"""
    <%= for {child, children} <- @tree do %>
      <.item item={child} children={children} />
    <% end %>
    """
  end

  def item(assigns) do
    ~H"""
    ID: <%= @item.id %> | Content: <.item_content item={@item} /> |
    <button phx-click="save" phx-value-id={@item.id}>Save</button> |
    <button phx-click="delete" phx-value-id={@item.id}>Delete</button>
    <ul class="list-disc list-outside ml-4">
      <%= for {child, children} <- @children do %>
        <li>
          <.item item={child} children={children} />
        </li>
      <% end %>
    </ul>
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

  def handle_event("save", %{"id" => id}, socket) do
    # TODO: access control, args are unsigned
    item = id |> Outliner.get_item!() |> dbg()

    # {field, value} =
    #   case dbg(item.kind) do
    #     :text -> {:text, socket.assigns.item.text}
    #     :url -> {:url, socket.assigns.item.url}
    #   end

    # {:ok, _} = Outliner.update_item(item, %{field => value})

    {:noreply, socket}
  end

  def handle_event("focus-content", %{"id" => id}, socket) do
    # id = String.to_integer(id)

    # items =
    #   socket.assigns.items
    #   |> dbg()
    #   |> Enum.map(fn
    #     {%Item{id: ^id} = item, _} = item ->
    #     item -> item
    #   end)

    # {:noreply, assign(socket, items: items)}
    {:noreply, socket}
  end

  def handle_event("blur-content", %{"id" => id}, socket) do
    # item = Enum.find(socket.assigns.items, &(&1.id == id))
    {:noreply, socket}
  end
end
