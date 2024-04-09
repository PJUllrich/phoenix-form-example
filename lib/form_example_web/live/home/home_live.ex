defmodule FormExampleWeb.HomeLive do
  use FormExampleWeb, :live_view

  alias FormExample.Orders.Order
  alias FormExample.Businesses

  alias FormExampleWeb.HomeLive.HomeForm

  alias Phoenix.HTML.Form

  def render(assigns) do
    ~H"""
    <div>
      <div class="w-full flex justify-between">
        <h1 :if={!@business} class="text-2xl font-semibold">Create a new business</h1>
        <h1 :if={@business} class="text-2xl font-semibold">Edit business <%= @business.id %></h1>
        <.link :if={@business} patch={~p"/"} class="font-semibold">
          <.icon name="hero-plus-circle" /> Create new business
        </.link>
      </div>

      <.form for={@form} phx-change="validate" phx-submit="submit" class="space-y-6">
        <%!-- Profile Inputs --%>
        <.inputs_for :let={profile} field={@form[:profile]}>
          <.input field={profile[:name]} type="text" label="Profile Name" />
          <.inputs_for :let={business} field={@form[:business]}>
            <.input
              field={profile[:business_id]}
              type="hidden"
              value={Form.input_value(business, :id)}
            />
          </.inputs_for>
        </.inputs_for>

        <%!-- Business Inputs --%>
        <.inputs_for :let={business} field={@form[:business]}>
          <.input field={business[:name]} type="text" label="Business Name" />
        </.inputs_for>

        <%!-- Order Inputs --%>
        <div class="space-y-8">
          <.inputs_for :let={order} field={@form[:orders]}>
            <div class="w-full grid grid-cols-2 gap-x-2">
              <.input field={order[:amount]} type="number" label="Order Amount" />
              <.input
                field={order[:status]}
                type="select"
                label="Order Status"
                options={Order.valid_statuses()}
              />
              <.inputs_for :let={business} field={@form[:business]}>
                <.input
                  field={order[:business_id]}
                  type="hidden"
                  value={Form.input_value(business, :id)}
                />
              </.inputs_for>
            </div>
          </.inputs_for>
        </div>
        <div class="w-full flex justify-between">
          <.button
            phx-click="add_order"
            type="button"
            class="bg-gray-300 hover:bg-gray-400 text-black"
          >
            Add order
          </.button>
          <.button type="submit">Submit</.button>
        </div>
      </.form>
      <div class="mt-20 space-y-4">
        <h2 class="font-semibold text-xl">Existing Businesses</h2>
        <div :for={business <- @businesses} class="hover:underline">
          <.link patch={~p"/#{business}"}>
            <%= business.id %> <%= business.name %>
            <.icon name="hero-arrow-top-right-on-square" class="w-4 h-4" />
          </.link>
        </div>
      </div>
    </div>
    """
  end

  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, params, socket.assigns.live_action)}
  end

  defp apply_action(socket, _params, :new) do
    form = HomeForm.new() |> to_form(as: :form)
    assign(socket, form: form, business: nil) |> assign_businesses()
  end

  defp apply_action(socket, %{"business_id" => id}, :edit) do
    business = Businesses.get_business!(id)

    base = %HomeForm{
      business: business,
      profile: business.profile,
      orders: business.orders
    }

    form = base |> HomeForm.changeset(%{}) |> to_form(as: :form)
    assign(socket, form: form, business: business) |> assign_businesses()
  end

  # TODO: Implement adding an order
  def handle_event("add_order", _params, socket) do
    IO.inspect(socket.assigns.form)
    {:noreply, socket}
  end

  def handle_event("validate", %{"form" => params}, socket) do
    form =
      socket.assigns.form.source.data
      |> HomeForm.changeset(params)
      |> Map.put(:action, :validate)
      |> to_form(as: :form)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("submit", %{"form" => params}, socket) do
    form = socket.assigns.form

    with {:ok, data} <- HomeForm.validate(form.source.data, params),
         {:ok, records} <- handle_submit(data, form, params, socket.assigns.live_action) do
      socket = socket |> put_flash(:info, "Success!") |> push_patch(to: ~p"/#{records.business}")
      {:noreply, socket}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :form))}
    end
  end

  defp handle_submit(data, _form, _params, :new) do
    data |> HomeForm.to_new_data() |> Businesses.register_business()
  end

  defp handle_submit(_data, form, params, :edit) do
    changeset = HomeForm.changeset(form.source.data, params)
    Businesses.update_business(changeset.changes)
  end

  defp assign_businesses(socket) do
    assign(socket, :businesses, Businesses.list_businesses())
  end
end
