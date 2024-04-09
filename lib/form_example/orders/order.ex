defmodule FormExample.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias FormExample.Businesses.Business

  @statuses [:draft, :paid, :refunded]

  schema "orders" do
    field :amount, :integer
    field :status, Ecto.Enum, values: @statuses

    belongs_to :business, Business

    timestamps(type: :utc_datetime)
  end

  def valid_statuses(), do: @statuses

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:business_id, :amount, :status])
    |> validate_required([:business_id, :amount, :status])
    |> validate_number(:amount, greater_than: 0)
  end
end
