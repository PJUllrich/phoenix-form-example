defmodule FormExample.Businesses.Business do
  use Ecto.Schema
  import Ecto.Changeset

  alias FormExample.Orders.Order
  alias FormExample.Profiles.Profile

  schema "businesses" do
    field :name, :string

    has_one :profile, Profile
    has_many :orders, Order

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(business, attrs) do
    business
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 5)
  end
end
