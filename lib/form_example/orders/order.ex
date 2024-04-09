defmodule FormExample.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias FormExample.Businesses.Business

  @valid_statutes [:draft, :paid, :refunded]

  schema "orders" do
    field :amount, :integer
    field :status, Ecto.Enum, values: @valid_statutes

    belongs_to :business, Business

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:amount, :status])
    |> validate_required([:amount, :status])
    |> validate_number(:amount, greater_than: 0)
  end
end
