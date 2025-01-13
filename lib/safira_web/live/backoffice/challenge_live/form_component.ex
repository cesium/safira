defmodule SafiraWeb.ChallengeLive.FormComponent do
  use SafiraWeb, :live_component

  alias Safira.Challenges
  alias Safira.Challenges.Challenge
  import SafiraWeb.Components.Forms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>
          The Challenges attendee participate in order to win prizes.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="challenge-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.field field={@form[:name]} type="text" label="Name" required />
        <div class="grid grid-cols-3 space-x-4">
          <.field field={@form[:type]} type="select" options={type_options()} label="Type" required />
          <.field field={@form[:date]} type="date" label="Date" />
          <.field field={@form[:display_priority]} type="number" label="Display Position" />
        </div>
        <.field field={@form[:description]} type="textarea" label="Description" required />

        <h3 class="font-semibold leading-8"><%= gettext("Prizes") %></h3>

        <.inputs_for :let={prizes_form} field={@form[:prizes]}>
          <input type="hidden" name="challenge[prizes_sort][]" value={prizes_form.index} />
          <div class="grid grid-cols-11 space-x-4">
            <.field
              field={prizes_form[:prize_id]}
              type="select"
              options={prize_options(@prizes)}
              label="Prize"
              wrapper_class="w-full col-span-5"
              required
            />
            <.field
              field={prizes_form[:place]}
              type="number"
              label="Place"
              wrapper_class="col-span-5"
              required
            />
            <button
              type="button"
              name="challenge[prizes_drop][]"
              value={prizes_form.index}
              phx-click={JS.dispatch("change")}
              class="flex items-center justify-end"
            >
              <.icon name="hero-trash" class="w-6 h-6" />
            </button>
          </div>
        </.inputs_for>

        <input type="hidden" name="challenge[prizes_drop][]" />

        <:actions>
          <button
            type="button"
            name="challenge[prizes_sort][]"
            value="new"
            phx-click={JS.dispatch("change")}
            class="phx-submit-loading:opacity-75 rounded-lg bg-dark text-light dark:bg-light dark:text-dark hover:bg-darkShade dark:hover:bg-lightShade/95 py-2 px-3 text-sm font-semibold leading-6 transition-colors "
          >
            <%= gettext("New Prize") %>
          </button>

          <.button phx-disable-with="Saving...">Save Challenge</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{challenge: challenge} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Challenges.change_challenge(challenge))
     end)}
  end

  @impl true
  def handle_event("validate", %{"challenge" => challenge_params}, socket) do
    changeset = Challenges.change_challenge(socket.assigns.challenge, challenge_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"challenge" => challenge_params}, socket) do
    save_challenge(socket, socket.assigns.action, challenge_params)
  end

  defp save_challenge(socket, :edit, challenge_params) do
    case Challenges.update_challenge(socket.assigns.challenge, challenge_params) do
      {:ok, _challenge} ->
        {:noreply,
         socket
         |> put_flash(:info, "Challenge updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_challenge(socket, :new, challenge_params) do
    case Challenges.create_challenge(challenge_params) do
      {:ok, _challenge} ->
        {:noreply,
         socket
         |> put_flash(:info, "Challenge created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp type_options do
    Enum.map(Challenge.challenge_types(), fn st ->
      {Atom.to_string(st) |> String.capitalize(), st}
    end)
  end

  defp prize_options(prizes) do
    Enum.map(prizes, &{&1.name, &1.id})
  end
end
