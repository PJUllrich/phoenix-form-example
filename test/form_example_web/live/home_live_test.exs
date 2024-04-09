defmodule FormExampleWeb.HomeLiveTest do
  use FormExampleWeb.ConnCase, async: true

  alias FormExample.Businesses

  import FormExample.BusinessesFixtures
  import FormExample.OrdersFixtures
  import FormExample.ProfilesFixtures

  describe "live_action: new" do
    test "creates a new business with profile and orders", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert view
             |> element("form")
             |> render_submit(%{
               "form" => %{
                 "business" => %{"id" => "1", "name" => "business name"},
                 "profile" => %{"id" => "1", "name" => "profi", "business_id" => "1"},
                 "orders" => %{
                   "0" => %{
                     "id" => "0",
                     "amount" => "123",
                     "status" => "paid",
                     "business_id" => "1"
                   },
                   "1" => %{
                     "id" => "1",
                     "amount" => "456",
                     "status" => "refunded",
                     "business_id" => "1"
                   }
                 }
               }
             }) =~ "Success!"

      [business] = Businesses.list_businesses()
      business = Businesses.get_business!(business.id)

      assert business.name == "business name"
      assert business.profile.name == "profi"

      [order_1, order_2] = Enum.sort_by(business.orders, & &1.id)
      assert order_1.amount == 123
      assert order_1.status == :paid

      assert order_2.amount == 456
      assert order_2.status == :refunded
    end
  end

  describe "live_action: :edit" do
    test "edits an existing business", %{conn: conn} do
      business = business_fixture()
      profile = profile_fixture(%{business_id: business.id})
      order = order_fixture(%{business_id: business.id})

      {:ok, view, _html} = live(conn, ~p"/#{business}")

      assert has_element?(view, ~s(input[name="form[profile][name]"][value="#{profile.name}"]))
      assert has_element?(view, ~s(input[name="form[business][name]"][value="#{business.name}"]))

      assert has_element?(
               view,
               ~s(input[name="form[orders][0][amount]"][value="#{order.amount}"])
             )

      assert has_element?(view, ~s(select[name="form[orders][0][status]"]))
      assert has_element?(view, ~s(option[value="#{order.status}"][selected]))

      assert view
             |> element("form")
             |> render_submit(%{
               "form" => %{
                 "business" => %{"id" => business.id, "name" => "new business name"},
                 "profile" => %{
                   "id" => profile.id,
                   "name" => "profi1",
                   "business_id" => business.id
                 },
                 "orders" => %{
                   "0" => %{
                     "id" => order.id,
                     "amount" => "456",
                     "status" => "draft",
                     "business_id" => business.id
                   }
                 }
               }
             }) =~ "Success!"

      assert has_element?(view, ~s(input[name="form[profile][name]"][value="profi1"]))
      assert has_element?(view, ~s(input[name="form[business][name]"][value="new business name"]))
      assert has_element?(view, ~s(input[name="form[orders][0][amount]"][value="456"]))
      assert has_element?(view, ~s(option[value="draft"][selected]))

      business = Businesses.get_business!(business.id)

      assert business.name == "new business name"

      assert business.profile.id == profile.id
      assert business.profile.name == "profi1"

      [res_order] = Enum.sort_by(business.orders, & &1.id)
      assert res_order.id == order.id
      assert res_order.amount == 456
      assert res_order.status == :draft
    end

    test "deletes existing orders", %{conn: conn} do
      assert false
    end

    test "updates existing orders", %{conn: conn} do
      assert false
    end

    test "creates new orders", %{conn: conn} do
      # create at least two orders
      assert false
    end
  end
end
