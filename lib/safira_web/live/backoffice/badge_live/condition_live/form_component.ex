defmodule SafiraWeb.Backoffice.BadgeLive.ConditionLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Contest
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.flash_group flash={@flash} />
      <.page
        title={@title}
        subtitle={
          gettext(
            "If the following statement is true, for any attendee, the badge is automatically awarded to them."
          )
        }
      >
        <.simple_form
          for={@form}
          id="condition-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="w-full space-y-2 text-dark dark:text-light">
            <div class="flex flex-row gap-2 items-center flex-wrap">
              <p>
                <%= gettext("An attendee has") %>
              </p>
              <.field
                name="amount_type"
                label=""
                value={@amount_type}
                label_class="hidden"
                wrapper_class="!mb-0 w-28"
                type="select"
                options={required_amount_options()}
              />
              <.field
                :if={@amount_type == "number"}
                field={@form[:amount_needed]}
                label_class="hidden"
                wrapper_class="!mb-0 w-24 relative"
                type="number"
              />
              <p>
                <%= gettext("badges of") %>
              </p>
              <.field
                field={@form[:category_id]}
                label_class="hidden"
                wrapper_class="!mb-0 w-38"
                type="select"
                options={categories_options(@categories)}
              />
              <p>
                <%= gettext("category, award them %{badge_name}.", badge_name: @badge.name) %>
              </p>
            </div>
            <div class="flex flex-row items-center gap-2">
              <p>
                <%= gettext("Check condition from") %>
              </p>
              <.field field={@form[:begin]} label="" wrapper_class="!mb-0 w-48" type="datetime-local" />
              <p>
                <%= gettext("to") %>
              </p>
              <.field field={@form[:end]} label="" wrapper_class="!mb-0 w-48" type="datetime-local" />
              .
            </div>
          </div>
          <:actions>
            <.button phx-disable-with="Saving...">Save Condition</.button>
          </:actions>
        </.simple_form>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> assign(:categories, Contest.list_badge_categories())}
  end

  @impl true
  def update(%{badge_condition: condition} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(
       :amount_type,
       if assigns.badge_condition.amount_needed do
         "number"
       else
         "all"
       end
     )
     |> assign_new(:form, fn ->
       to_form(Contest.change_badge_condition(condition))
     end)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"badge_condition" => badge_condition_params, "amount_type" => amount_type},
        socket
      ) do
    changeset =
      Contest.change_badge_condition(socket.assigns.badge_condition, badge_condition_params)

    {:noreply,
     assign(socket, form: to_form(changeset, action: :validate), amount_type: amount_type)}
  end

  def handle_event("save", %{"badge_condition" => badge_condition_params}, socket) do
    params =
      if socket.assigns.amount_type == "all" do
        Map.put(badge_condition_params, "amount_needed", nil)
      else
        badge_condition_params
      end

    save_condition(
      socket,
      socket.assigns.action,
      Map.put(params, "badge_id", socket.assigns.badge.id)
    )
  end

  defp save_condition(socket, :conditions_edit, badge_condition_params) do
    case Contest.update_badge_condition(socket.assigns.badge_condition, badge_condition_params) do
      {:ok, _condition} ->
        {:noreply,
         socket
         |> put_flash(:info, "Badge condition updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_condition(socket, :conditions_new, badge_condition_params) do
    case Contest.create_badge_condition(badge_condition_params) do
      {:ok, _condition} ->
        {:noreply,
         socket
         |> put_flash(:info, "Badge condition added successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp categories_options(categories) do
    Enum.map([%{name: "Any", id: nil}] ++ categories, &{&1.name, &1.id})
  end

  defp required_amount_options do
    [{"all", :all}, {"at least", :number}]
  end
end
