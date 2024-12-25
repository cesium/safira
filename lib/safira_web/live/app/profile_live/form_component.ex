defmodule SafiraWeb.App.ProfileLive.FormComponent do
  use SafiraWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page
        title="Options"
        subtitle={gettext("Customize your profile.")}
        title_class="text-2xl text-black dark:text-white"
      >
        <div class="flex flex-col md:flex-row w-full gap-4 dark:text-zinc-400">
          <div class="w-full space-y-2">
            <DarkMode.button />
          </div>
        </div>
      </.page>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, socket}
  end
end
