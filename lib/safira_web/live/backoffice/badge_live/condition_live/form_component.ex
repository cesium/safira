defmodule SafiraWeb.Backoffice.BadgeLive.ConditionLive.FormComponent do
  alias Safira.Moon
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
          gettext("When this logic gets executed as truthy, the badge is awarded to the attendee.")
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
            <div class="flex flex-row gap-2 items-center">
              <p>
                <%= gettext("When an attendee receives a badge of type") %>
              </p>
              <.field
                field={@form[:category_id]}
                label_class="hidden"
                wrapper_class="!mb-0 w-40"
                type="select"
                options={categories_options(@categories)}
              />
              <p>
                <%= gettext("and:") %>
              </p>
            </div>
            <div>
              <.field field={@form[:logic]} label_class="hidden" wrapper_class="!mb-0" type="lua" />
            </div>
            <p>
              <%= gettext("award them %{badge_name}.", badge_name: @badge.name) %>
            </p>
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
     |> assign_new(:form, fn ->
       to_form(Contest.change_badge_condition(condition))
     end)}
  end

  @impl true
  def handle_event("validate", %{"badge_condition" => badge_condition_params}, socket) do
    changeset =
      Contest.change_badge_condition(socket.assigns.badge_condition, badge_condition_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"badge_condition" => badge_condition_params}, socket) do
    if Map.get(badge_condition_params, "logic", nil) &&
         badge_condition_params["logic"] |> String.trim() != "" do
      case Moon.eval(badge_condition_params["logic"], attendee: %{badges: []}) do
        {:ok, result} ->
          if result in [true, false] do
            save_condition(
              socket,
              socket.assigns.action,
              badge_condition_params |> Map.put("badge_id", socket.assigns.badge.id)
            )
          else
            {:noreply,
             socket
             |> put_flash(
               :error,
               "The logic must return a boolean value (got #{inspect(result)})"
             )}
          end

        {:error, message} ->
          {:noreply, socket |> put_flash(:error, message)}
      end
    else
      save_condition(
        socket,
        socket.assigns.action,
        badge_condition_params |> Map.put("badge_id", socket.assigns.badge.id)
      )
    end
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
end
