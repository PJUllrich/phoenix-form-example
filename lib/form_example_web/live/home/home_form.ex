defmodule FormExampleWeb.HomeLive.HomeForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :profile_name, :string
    field :business_name, :string

    embeds_many :orders, Order, on_replace: :delete, primary_key: {:id, :id, autogenerate: false} do
      field :amount, :integer
      field :status, Ecto.Enum, values: Ecto.Enum.mappings(FormExample.Orders.Order, :status)

      timestamps(type: :utc_datetime)
    end
  end

  def changeset(struct_or_changeset, attrs) do
    struct_or_changeset
    |> cast(attrs, [:id, :profile_name, :business_name])
    |> cast_embed(:orders,
      with: &order_changeset/2,
      sort_param: :orders_sort,
      drop_param: :orders_drop
    )
    |> validate_required([:profile_name, :business_name])
  end

  def order_changeset(struct_or_changeset, attrs) do
    struct_or_changeset
    |> cast(attrs, [:id, :amount, :status])
    |> validate_required([:amount, :status])
    |> validate_number(:amount, greater_than: 0)
  end
end
