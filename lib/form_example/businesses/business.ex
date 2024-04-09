defmodule FormExample.Businesses.Business do
  use Ecto.Schema
  import Ecto.Changeset

  alias FormExample.Orders.Order
  alias FormExample.Profiles.Profile

  schema "businesses" do
    field :name, :string

    has_one :profile, Profile, on_replace: :update
    has_many :orders, Order, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(business, attrs) do
    business
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
