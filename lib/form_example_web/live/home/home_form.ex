defmodule FormExampleWeb.HomeLive.HomeForm do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  alias FormExample.Businesses.Business
  alias FormExample.Orders.Order
  alias FormExample.Profiles.Profile

  embedded_schema do
    embeds_one :profile, Profile, on_replace: :update
    embeds_one :business, Business, on_replace: :update
    embeds_many :orders, Order, on_replace: :delete
  end

  def new() do
    form = %HomeForm{
      profile: %Profile{business_id: 1},
      business: %Business{id: 1},
      orders: [%Order{id: 0, business_id: 1}]
    }

    changeset(form, %{})
  end

  def changeset(struct_or_changeset, attrs) do
    struct_or_changeset
    |> cast(attrs, [])
    |> cast_embed(:profile, with: &Profile.changeset/2)
    |> cast_embed(:business, with: &Business.changeset/2)
    |> cast_embed(:orders, with: &Order.changeset/2)
  end

  def validate(struct_or_changeset, attrs) do
    struct_or_changeset
    |> changeset(attrs)
    |> apply_action(:insert)
  end

  def to_new_data(form) do
    business = Map.put(form.business, :id, nil)
    profile = Map.put(form.profile, :id, nil)
    orders = to_map(form.orders)

    %{business: business, profile: profile, orders: orders}
  end

  def to_update_data(form) do
    changeset(form.source.data, %{})
  end

  defp to_map(structs) when is_list(structs) do
    Enum.map(structs, &to_map/1)
  end

  defp to_map(struct) when is_struct(struct) do
    struct
    |> Map.from_struct()
    |> Map.drop([:id, :__meta__, :business, :business_id, :inserted_at, :updated_at])
  end
end
