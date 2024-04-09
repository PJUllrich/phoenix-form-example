defmodule FormExample.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :status, :string
      add :amount, :integer
      add :business_id, references(:businesses, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:orders, [:business_id])
  end
end
