defmodule FormExampleWeb.HomeLive do
  use FormExampleWeb, :live_view
  alias FormExampleWeb.HomeLive.HomeForm

  def render(assigns) do
    ~H"""
    <.form for={@form} phx-change="validate" phx-submit="submit">
      <.input field={@form[:profile_name]} type="text" label="Profile Name" />
      <.input field={@form[:business_name]} type="text" label="Business Name" />
      <fieldset class="my-4">
        <label class="block">Orders</label>
        <.inputs_for :let={f_order} field={@form[:orders]}>
          <div class="flex w-full gap-4">
            <input type="hidden" name="form[orders_sort][]" value={f_order.index} />
            <div class="flex-1">
              <.input
                field={f_order[:status]}
                label="Status"
                type="select"
                options={Ecto.Enum.mappings(HomeForm.Order, :status)}
                prompt="Select status"
              />
            </div>
            <div class="flex-1">
              <.input field={f_order[:amount]} label="Amount" type="number" />
            </div>
            <.button
              type="button"
              class="self-end"
              name="form[orders_drop][]"
              value={f_order.index}
              phx-click={JS.dispatch("change")}
            >
              <.icon name="hero-x-mark" class="w-6 h-6 relative" />
            </.button>
          </div>
        </.inputs_for>

        <input type="hidden" name="form[orders_drop][]" />

        <.button
          type="button"
          name="form[orders_sort][]"
          value="new"
          phx-click={JS.dispatch("change")}
        >
          add more
        </.button>
      </fieldset>
      <.button type="submit">Submit</.button>
    </.form>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, params, socket.assigns.live_action)}
  end

  defp apply_action(socket, _params, :new) do
    base = %HomeForm{profile_name: "", business_name: "", orders: []}
    form = base |> HomeForm.changeset(%{}) |> to_form(as: :form)
    assign(socket, form: form)
  end

  defp apply_action(socket, %{"business_id" => id}, :edit) do
    business =
      FormExample.Businesses.Business
      |> FormExample.Repo.get(id)
      |> FormExample.Repo.preload([:profile, :orders])

    base = %HomeForm{
      id: business.id,
      profile_name: business.profile.name,
      business_name: business.name,
      orders:
        Enum.map(business.orders, fn order ->
          %HomeForm.Order{
            id: order.id,
            amount: order.amount,
            status: order.status
          }
        end)
    }

    form = base |> HomeForm.changeset(%{}) |> to_form(as: :form)
    assign(socket, form: form, business: business)
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
    changeset =
      socket.assigns.form.source.data
      |> HomeForm.changeset(params)

    case Ecto.Changeset.apply_action(changeset, :create) do
      {:ok, data} ->
        business =
          if data.id do
            current_business = socket.assigns.business

            current_business
            |> Ecto.Changeset.change(name: data.business_name)
            |> Ecto.Changeset.put_assoc(:profile, %{name: data.profile_name})
            |> Ecto.Changeset.put_assoc(
              :orders,
              Enum.map(data.orders, fn order ->
                %{
                  id: order.id,
                  amount: order.amount,
                  status: order.status
                }
              end)
            )
            |> IO.inspect()
            |> FormExample.Repo.update!()
          else
            %FormExample.Businesses.Business{
              name: data.business_name,
              profile: %FormExample.Profiles.Profile{name: data.profile_name},
              orders:
                Enum.map(data.orders, fn order ->
                  %FormExample.Orders.Order{
                    amount: order.amount,
                    status: order.status
                  }
                end)
            }
            |> FormExample.Repo.insert!()
          end

        {:noreply, redirect(socket, to: ~p"/#{business.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: :form))}
    end
  end
end
