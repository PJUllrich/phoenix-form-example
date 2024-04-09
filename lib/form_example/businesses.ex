defmodule FormExample.Businesses do
  @moduledoc """
  The Businesses context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias FormExample.Repo

  alias FormExample.Orders.Order
  alias FormExample.Businesses.Business

  @doc """
  Returns the list of businesses.

  ## Examples

      iex> list_businesses()
      [%Business{}, ...]

  """
  def list_businesses do
    Repo.all(Business)
  end

  @doc """
  Gets a single business.

  Raises `Ecto.NoResultsError` if the Business does not exist.

  ## Examples

      iex> get_business!(123)
      %Business{}

      iex> get_business!(456)
      ** (Ecto.NoResultsError)

  """
  def get_business!(id) do
    Business
    |> Repo.get!(id)
    |> Repo.preload([:profile, :orders])
  end

  @doc """
  Creates a business.

  ## Examples

      iex> create_business(%{field: value})
      {:ok, %Business{}}

      iex> create_business(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_business(attrs \\ %{}) do
    %Business{}
    |> Business.changeset(attrs)
    |> Repo.insert()
  end

  def register_business(%{business: business, profile: profile, orders: orders} = _data) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:business, business)
    |> Ecto.Multi.insert(:profile, fn %{business: business} ->
      Map.put(profile, :business_id, business.id)
    end)
    |> Ecto.Multi.insert_all(
      :orders,
      Order,
      fn %{business: business} ->
        Enum.map(orders, fn order ->
          Map.merge(order, %{
            business_id: business.id,
            inserted_at: {:placeholder, :now},
            updated_at: {:placeholder, :now}
          })
        end)
      end,
      placeholders: %{now: now}
    )
    |> Repo.transaction()
  end

  def update_business(data) do
    Ecto.Multi.new()
    |> maybe_update_business(data)
    |> maybe_update_profile(data)
    |> maybe_update_orders(data)
    |> Repo.transaction()
  end

  defp maybe_update_business(multi, %{business: business}) do
    Ecto.Multi.update(multi, :business, business)
  end

  defp maybe_update_business(multi, _params), do: multi

  defp maybe_update_profile(multi, %{profile: profile}) do
    Ecto.Multi.update(multi, :profile, profile)
  end

  defp maybe_update_profile(multi, _params), do: multi

  defp maybe_update_orders(multi, %{orders: orders}) do
    orders
    |> Enum.with_index()
    |> Enum.reduce(multi, fn {order, idx}, multi ->
      case order.action do
        :replace ->
          order = Changeset.apply_action!(order, :delete)
          Ecto.Multi.delete(multi, "order-#{idx}", order)

        :update ->
          Ecto.Multi.update(multi, "order-#{idx}", order)

        :insert ->
          Ecto.Multi.insert(multi, "order-#{idx}", order)
      end
    end)
  end

  defp maybe_update_orders(multi, _params), do: multi

  @doc """
  Updates a business.

  ## Examples

      iex> update_business(business, %{field: new_value})
      {:ok, %Business{}}

      iex> update_business(business, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_business(%Business{} = business, attrs) do
    business
    |> Business.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a business.

  ## Examples

      iex> delete_business(business)
      {:ok, %Business{}}

      iex> delete_business(business)
      {:error, %Ecto.Changeset{}}

  """
  def delete_business(%Business{} = business) do
    Repo.delete(business)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking business changes.

  ## Examples

      iex> change_business(business)
      %Ecto.Changeset{data: %Business{}}

  """
  def change_business(%Business{} = business, attrs \\ %{}) do
    Business.changeset(business, attrs)
  end
end
