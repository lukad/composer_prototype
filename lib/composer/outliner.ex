defmodule Composer.Outliner do
  @moduledoc """
  The Outliner context.
  """

  import Ecto.Query, warn: false
  alias EctoLtree.LabelTree, as: Ltree
  alias Composer.Repo

  alias Composer.Outliner.Item

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(Item)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end

  def subtree(start_id) when is_binary(start_id) do
    start_id
    |> String.to_integer()
    |> subtree()
  end

  def subtree(start_id) when is_integer(start_id) do
    query =
      from i1 in Item,
        join: i2 in Item,
        on:
          fragment(
            "? <@ (? || text2ltree(?)) or ? = ?",
            i1.path,
            i2.path,
            ^Integer.to_string(start_id),
            i1.id,
            ^start_id
          ),
        where: i2.id == ^start_id,
        order_by: fragment("i0.path || text2ltree(i0.id::text) ASC, i0.sort_key ASC, i0.id ASC"),
        select: i1

    Repo.all(query)
  end

  @doc """
  Arranges items into a tree.
  [
    {top1, [
      {child, [
        {grandchild, []}
      ]}
    },
    {top2, []}
  ]
  """
  def arrange(items) do
    min_depth =
      Enum.map(items, fn %{path: %{labels: path}} -> length(path |> Enum.reject(&(&1 == ""))) end)
      |> Enum.min()

    arrange(items, [], min_depth)
  end

  defp arrange([], acc, _min_depth), do: acc

  defp arrange(items, acc, min_depth) do
    {current_level, rest} =
      Enum.split_with(items, fn %{path: %{labels: path}} ->
        length(path |> Enum.reject(&(&1 == ""))) == min_depth
      end)

    current_level_trees =
      current_level
      |> Enum.sort_by(& &1.id)
      |> Enum.map(fn item ->
        children = find_children(item.id, rest, min_depth)
        {item, arrange(children, [], min_depth + 1)}
      end)

    acc ++ current_level_trees
  end

  defp find_children(id, items, depth) do
    Enum.filter(items, fn %{path: %{labels: path}} ->
      Enum.at(path, depth) == Integer.to_string(id)
    end)
    |> Enum.sort_by(& &1.id)
  end
end
