defmodule Composer.OutlinerTest do
  use Composer.DataCase

  alias Composer.Outliner

  describe "items" do
    alias Composer.Outliner.Item

    import Composer.OutlinerFixtures

    @invalid_attrs %{path: nil, text: nil, kind: nil, url: nil}

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Outliner.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Outliner.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      valid_attrs = %{path: [], text: "some text", kind: :text, url: "some url"}

      assert {:ok, %Item{} = item} = Outliner.create_item(valid_attrs)
      assert item.path == []
      assert item.text == "some text"
      assert item.kind == :text
      assert item.url == "some url"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Outliner.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      update_attrs = %{path: [], text: "some updated text", kind: :url, url: "some updated url"}

      assert {:ok, %Item{} = item} = Outliner.update_item(item, update_attrs)
      assert item.path == []
      assert item.text == "some updated text"
      assert item.kind == :url
      assert item.url == "some updated url"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Outliner.update_item(item, @invalid_attrs)
      assert item == Outliner.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Outliner.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Outliner.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Outliner.change_item(item)
    end
  end
end
