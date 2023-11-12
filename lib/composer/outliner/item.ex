defmodule Composer.Outliner.Item do
  use Ecto.Schema
  import Ecto.Changeset
  alias EctoLtree.LabelTree, as: Ltree

  schema "items" do
    field :kind, Ecto.Enum, values: [:text, :url]
    field :text, :string
    field :url, :string
    field :path, Ltree

    # has_many :children, __MODULE__
    # belongs_to :parent, __MODULE__

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:kind, :text, :url, :path])
    |> validate_required([:kind])
    |> validate_content()
  end

  def validate_content(%Ecto.Changeset{changes: %{kind: :text}} = changeset) do
    validate_required(changeset, [:text])
  end

  def validate_content(%Ecto.Changeset{changes: %{kind: :url}} = changeset) do
    validate_required(changeset, [:url])
  end
end
