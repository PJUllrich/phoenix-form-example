defmodule FormExample.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FormExample.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        amount: 123,
        status: :draft
      })
      |> FormExample.Orders.create_order()

    order
  end
end
