defmodule Composer.Repo.Migrations.CreateItems do
  use Ecto.Migration

  # def change do
  #   create table(:items) do
  #     add :kind, :string, null: false
  #     add :text, :string
  #     add :url, :string
  #     add :parent_id, references(:items)

  #     timestamps()
  #   end

  #   create index(:items, [:parent_id])
  # end

  def change do
    execute("CREATE EXTENSION ltree;", "DROP EXTENSION ltree;")

    execute("CREATE TYPE item_kind AS ENUM ('text', 'url');", "DROP TYPE item_kind;")

    create table(:items) do
      add :kind, :item_kind, null: false
      add :text, :string
      add :url, :string
      add :path, :ltree, null: false, default: ""
      add :sort_key, :integer, null: false, default: 0

      timestamps()
    end

    create index(:items, [:path], using: :gist)
    create index(:items, [:sort_key], using: :btree)
  end
end
