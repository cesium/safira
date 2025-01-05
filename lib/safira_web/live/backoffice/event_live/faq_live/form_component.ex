defmodule SafiraWeb.Backoffice.EventLive.FaqLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Event
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title={@title}
        subtitle={gettext("FAQs are publicly available on the event's landing page.")}
      >
        <.simple_form
          for={@form}
          id="faq-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <div class="w-full space-y-2">
            <.field field={@form[:question]} type="text" label="Question" required />
            <.field field={@form[:answer]} type="textarea" required />
          </div>
          <:actions>
            <.button phx-disable-with="Saving...">Save FAQ</.button>
          </:actions>
        </.simple_form>
      </.page>
    </div>
    """
  end

  @impl true
  def update(%{faq: faq} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Event.change_faq(faq))
     end)}
  end

  @impl true
  def handle_event("validate", %{"faq" => faq_params}, socket) do
    changeset = Event.change_faq(socket.assigns.faq, faq_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"faq" => faq_params}, socket) do
    save_faq(socket, socket.assigns.action, faq_params)
  end

  defp save_faq(socket, :faqs_edit, faq_params) do
    case Event.update_faq(socket.assigns.faq, faq_params) do
      {:ok, _faq} ->
        {:noreply,
         socket
         |> put_flash(:info, "FAQ updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_faq(socket, :faqs_new, faq_params) do
    case Event.create_faq(faq_params) do
      {:ok, _faq} ->
        {:noreply,
         socket
         |> put_flash(:info, "FAQ created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
