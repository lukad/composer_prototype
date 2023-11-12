# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Composer.Repo.insert!(%Composer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Composer.Outliner.Item
alias Composer.Outliner
alias Composer.Repo

Repo.delete_all(Item)

Repo.query("ALTER SEQUENCE items_id_seq RESTART WITH 1")

{:ok, root} = Outliner.create_item(%{kind: :text, text: "Root"})

max_depth = 5
max_children = 5

# create_children = fn parent, depth, create_children ->
#   if depth <= max_depth do
#     {:ok, item} =
#       Outliner.create_item(%{
#         kind: :text,
#         text: "Item",
#         parent_id: parent.id
#       })

#     children_amount = :rand.uniform(max_children + 1) - 1

#     0..children_amount
#     |> Enum.each(fn
#       0 -> :noop
#       _ -> create_children.(item, depth + 1, create_children)
#     end)
#   end
# end

create_children = fn parent, path, create_children ->
  if length(path) <= max_depth do
    {:ok, item} =
      Outliner.create_item(%{
        kind: :text,
        text: "Item",
        path: path |> Enum.map(&to_string/1) |> Enum.join(".")
      })

    0..max_children
    |> Enum.each(fn
      0 -> :noop
      _ -> create_children.(item, path ++ [item.id], create_children)
    end)
  end
end

create_children.(root, [root.id], create_children)

# 0..9
# |> Enum.reduce([root.id], fn _, path ->
#   {:ok, item} =
#     Outliner.create_item(%{
#       kind: :text,
#       text: "Item #{inspect(path, charlists: :as_lists)}",
#       path: path
#     })

#   path ++ [item.id]
# end)
