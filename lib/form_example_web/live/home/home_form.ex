defmodule FormExampleWeb.HomeLive.HomeForm do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  alias FormExample.Businesses.Business
  alias FormExample.Orders.Order
  alias FormExample.Profiles.Profile

  embedded_schema do
    embeds_one :business, Business, on_replace: :update
    embeds_one :profile, Profile, on_replace: :update
    embeds_many :orders, Order, on_replace: :delete

    # Helper fields for adding/deleting orders
    field :order_sort, {:array, :integer}
    field :order_drop, {:array, :integer}
  end

  def new() do
    form = %HomeForm{
      business: %Business{id: 1},
      profile: %Profile{business_id: 1},
      orders: []
    }

    changeset(form, %{})
  end

  def changeset(struct_or_changeset, attrs) do
    struct_or_changeset
    |> cast(attrs, [])
    |> cast_embed(:profile, with: &Profile.changeset/2)
    |> cast_embed(:business, with: &Business.changeset/2)
    |> cast_embed(:orders,
      with: &Order.changeset/2,
      sort_param: :order_sort,
      drop_param: :order_drop
    )
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
