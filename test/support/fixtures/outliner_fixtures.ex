defmodule Composer.OutlinerFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Composer.Outliner` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        kind: :text,
        path: [],
        text: "some text",
        url: "some url"
      })
      |> Composer.Outliner.create_item()

    item
  end
end
