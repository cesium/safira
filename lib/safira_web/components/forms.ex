defmodule SafiraWeb.Components.Forms do
  @moduledoc """
  Collection of fields to be used in conjunction with the `form` component from Phoenix.
  """
  use Phoenix.Component

  alias Phoenix.HTML

  @input_types ~w(
    checkbox
    checkbox-group
    color
    date
    datetime-local
    email
    file
    hidden
    month
    number
    password
    range
    radio-group
    search
    select
    switch
    tel
    text
    textarea
    time
    url
    week
    lua
  )

  @doc """
  Renders an input with label and error messages.

  A `%Phoenix.Html.FormField{}` and type must be passed to the component.

  ## Examples

    `<.field field={@form[:email]} type="email" />`
    `<.field label="Name" value="" name="name" errors={["can't be blank"]} />`
  """
  attr :id, :any, default: nil, doc: "The id of the input. If not provided, it will be generated."
  attr :name, :any, doc: "The name of the input. If not provided, it will be generated."
  attr :label, :string, doc: "The label for the input. If not provided, it will be generated."
  attr :value, :any, doc: "The value of the input. If not provided, it will be generated."
  attr :type, :string, default: "text", values: @input_types, doc: "The type of the input."

  attr :field, HTML.FormField,
    doc: "A form field struct retrieved from the form, for example: `@form[:email]`."

  attr :errors, :list,
    default: [],
    doc: "A list of erros to be displayed. If not provided, it will be generated."

  attr :checked, :any, doc: "The checked flag for checkboxes and checkboxes groups."

  attr :prompt, :string, default: nil, doc: "The prompt for select inputs."

  attr :options, :list,
    default: [],
    doc: "The options to pass to `Phoenix.HTML.Form.options_for_select/2`."

  attr :multiple, :boolean, default: false, doc: "The multiple flag for select inputs."
  attr :disabled_options, :list, default: [], doc: "The options to be disabled in select inputs."

  attr :group_layout, :string,
    values: ["row", "col"],
    default: "row",
    doc: "The layout for inputs in a group (checkboxes or radio button)."

  attr :empty_message, :string,
    default: nil,
    doc:
      "The message to be displayed when there are no options available for inputs in a group (checkboxes or radio button)."

  attr :rows, :integer, default: 4, doc: "The number of rows for textarea inputs."

  attr :selected, :any, default: nil, doc: "The selected value for select inputs."

  attr :class, :string, default: nil, doc: "The class to be added to the input."
  attr :wrapper_class, :string, default: nil, doc: "The wrapper div class."
  attr :label_class, :string, default: nil, doc: "Extra class for the label."
  attr :help_text, :string, default: nil, doc: "Context/help for the input."

  attr :required, :boolean,
    default: false,
    doc:
      "If the input is required. In positive cases, it will add the `required` attribute to the input and a `*` to the label."

  attr :rest, :global,
    include:
      ~w(autocomplete autocorrect autocapitalize disabled form max maxlength min minlength list pattern placeholder readonly required size step value name multiple prompt default year month day hour minute second builder options layout cols rows wrap checked accept),
    doc: "Any other attribute to be added to the input."

  def field(%{field: %HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn ->
      if assigns.multiple && assigns.type not in ["checkbox-group", "radio-group"],
        do: field.name <> "[]",
        else: field.name
    end)
    |> assign_new(:value, fn -> field.value end)
    |> assign_new(:label, fn -> humanize(field.field) end)
    |> field()
  end

  def field(%{type: "checkbox", value: value} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn -> HTML.Form.normalize_value("checkbox", value) end)

    ~H"""
    <.field_wrapper errors={@errors} name={@name} class={@wrapper_class}>
      <label class={["safira-checkbox-label", @label_class]}>
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          required={@required}
          class={["safira-checkbox", @class]}
          {@rest}
        />
        <div class={[@required && "safira-label--required"]}>
          <%= @label %>
        </div>
      </label>

      <.field_error :for={msg <- @errors}><%= msg %></.field_error>
      <.field_help_text help_text={@help_text} />
    </.field_wrapper>
    """
  end

  def field(%{type: "select"} = assigns) do
    ~H"""
    <.field_wrapper errors={@errors} name={@name} class={@wrapper_class}>
      <.field_label required={@required} for={@id} class={@label_class}>
        <%= @label %>
      </.field_label>

      <select
        id={@id}
        name={@name}
        class={["safira-select", @class]}
        multiple={@multiple}
        required={@required}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= HTML.Form.options_for_select(@options, @selected || @value) %>
      </select>

      <.field_error :for={msg <- @errors}><%= msg %></.field_error>
      <.field_help_text help_text={@help_text} />
    </.field_wrapper>
    """
  end

  def field(%{type: "textarea"} = assigns) do
    ~H"""
    <.field_wrapper errors={@errors} name={@name} class={@wrapper_class}>
      <.field_label required={@required} for={@id} class={@label_class}>
        <%= @label %>
      </.field_label>

      <textarea
        id={@id}
        name={@name}
        class={["safira-text-input", @class]}
        rows={@rows}
        required={@required}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>

      <.field_error :for={msg <- @errors}><%= msg %></.field_error>
      <.field_help_text help_text={@help_text} />
    </.field_wrapper>
    """
  end

  def field(%{type: "lua"} = assigns) do
    ~H"""
    <.field_wrapper errors={@errors} name={@name} class={@wrapper_class}>
      <.field_label required={@required} for={@id} class={@label_class}>
        <%= @label %>
      </.field_label>

      <textarea
        id={@id}
        spellCheck={false}
        autoComplete="off"
        autoCorrect="off"
        autoCapitalize="none"
        spellcheck="false"
        name={@name}
        class={["safira-text-input safira-text-code", @class]}
        rows={@rows}
        required={@required}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>

      <.field_error :for={msg <- @errors}><%= msg %></.field_error>
      <.field_help_text help_text={@help_text} />
    </.field_wrapper>
    """
  end

  def field(%{type: "switch", value: value} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn -> HTML.Form.normalize_value("checkbox", value) end)

    ~H"""
    <.field_wrapper errors={@errors} name={@name} class={@wrapper_class}>
      <label class={["safira-switch-label", @label_class]}>
        <input type="hidden" name={@name} value="false" />
        <label class="safira-switch">
          <input
            type="checkbox"
            id={@id}
            name={@name}
            value="true"
            checked={@checked}
            required={@required}
            class={["sr-only peer", @class]}
            {@rest}
          />

          <span class="safira-switch__fake-input"></span>
          <span class="safira-switch__fake-input-bg"></span>
        </label>
        <div><%= @label %></div>
      </label>

      <.field_error :for={msg <- @errors}><%= msg %></.field_error>
      <.field_help_text help_text={@help_text} />
    </.field_wrapper>
    """
  end

  def field(%{type: "checkbox-group"} = assigns) do
    assigns =
      assigns
      |> assign_new(:checked, fn ->
        values =
          case assigns.value do
            value when is_binary(value) -> [value]
            value when is_list(value) -> value
            _ -> []
          end

        Enum.map(values, &to_string/1)
      end)

    ~H"""
    <.field_wrapper errors={@errors} name={@name} class={@wrapper_class}>
      <.field_label required={@required} for={@id} class={@label_class}>
        <%= @label %>
      </.field_label>

      <input type="hidden" name={@name} value="" />
      <div class={[
        "safira-checkbox-group",
        @group_layout == "row" && "safira-checkbox-group--row",
        @group_layout == "col" && "safira-checkbox-group--col",
        @class
      ]}>
        <%= for {label, value} <- @options do %>
          <label class="safira-checkbox-label">
            <input
              type="checkbox"
              name={@name <> "[]"}
              checked_value={value}
              unchecked_value=""
              value={value}
              checked={to_string(value) in @checked}
              hidden_input={false}
              class="safira-checkbox"
              disabled={value in @disabled_options}
              {@rest}
            />
            <div>
              <%= label %>
            </div>
          </label>
        <% end %>

        <%= if @empty_message && Enum.empty?(@options) do %>
          <div class="safira-checkbox-group--empty-message">
            <%= @empty_message %>
          </div>
        <% end %>
      </div>

      <.field_error :for={msg <- @errors}><%= msg %></.field_error>
      <.field_help_text help_text={@help_text} />
    </.field_wrapper>
    """
  end

  def field(%{type: "radio-group"} = assigns) do
    assigns = assign_new(assigns, :checked, fn -> nil end)

    ~H"""
    <.field_wrapper errors={@errors} name={@name} class={@wrapper_class}>
      <.field_label required={@required} for={@id} class={@label_class}>
        <%= @label %>
      </.field_label>

      <div class={[
        "safira-radio-group",
        @group_layout == "row" && "safira-radio-group--row",
        @group_layout == "col" && "safira-radio-group--col",
        @class
      ]}>
        <input type="hidden" name={@name} value="" />
        <%= for {label, value} <- @options do %>
          <label class="safira-radio-label">
            <input
              type="radio"
              name={@name}
              value={value}
              checked={
                to_string(value) == to_string(@value) || to_string(value) == to_string(@checked)
              }
              class="safira-radio"
              {@rest}
            />
            <div>
              <%= label %>
            </div>
          </label>
        <% end %>

        <%= if @empty_message && Enum.empty?(@options) do %>
          <div class="safira-radio-group--empty-message">
            <%= @empty_message %>
          </div>
        <% end %>
      </div>

      <.field_error :for={msg <- @errors}><%= msg %></.field_error>
      <.field_help_text help_text={@help_text} />
    </.field_wrapper>
    """
  end

  def field(%{type: "hidden"} = assigns) do
    ~H"""
    <input
      type={@type}
      name={@name}
      id={@id}
      value={Phoenix.HTML.Form.normalize_value(@type, @value)}
      class={@class}
      {@rest}
    />
    """
  end

  # All other inputs: text, datetime-local, url, password, etc.
  def field(assigns) do
    assigns = assign(assigns, class: [assigns.class, get_class_for_type(assigns.type)])

    ~H"""
    <.field_wrapper errors={@errors} name={@name} class={@wrapper_class}>
      <.field_label required={@required} for={@id} class={@label_class}>
        <%= @label %>
      </.field_label>

      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={@class}
        required={@required}
        {@rest}
      />

      <.field_error :for={msg <- @errors}><%= msg %></.field_error>
      <.field_help_text help_text={@help_text} />
    </.field_wrapper>
    """
  end

  attr :class, :string, default: nil
  attr :errors, :list, default: []
  attr :name, :string
  attr :rest, :global
  slot :inner_block, required: true

  defp field_wrapper(assigns) do
    ~H"""
    <div
      phx-feedback-for={@name}
      {@rest}
      class={[
        @class,
        "safira-form-field-wrapper",
        @errors != [] && "safira-form-field-wrapper--error"
      ]}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :for, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global
  attr :required, :boolean, default: false
  slot :inner_block, required: true

  def field_label(assigns) do
    ~H"""
    <label for={@for} class={["safira-label", @class, @required && "safira-label--required"]} {@rest}>
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  slot :inner_block, required: true

  defp field_error(assigns) do
    ~H"""
    <p class="safira-form-field-error">
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  attr :class, :string, default: "", doc: "Extra class for the help text."
  attr :help_text, :string, default: "", doc: "Context/help for the field."
  slot :inner_block, required: false
  attr :rest, :global

  def field_help_text(assigns) do
    ~H"""
    <div
      :if={render_slot(@inner_block) || @help_text}
      class={["safira-form-help-text", @class]}
      {@rest}
    >
      <%= render_slot(@inner_block) || @help_text %>
    </div>
    """
  end

  defp get_class_for_type("radio"), do: "safira-radio"
  defp get_class_for_type("checkbox"), do: "safira-checkbox"
  defp get_class_for_type("color"), do: "safira-color-input"
  defp get_class_for_type("file"), do: "safira-file-input"
  defp get_class_for_type("range"), do: "safira-range-input"
  defp get_class_for_type(_), do: "safira-text-input"

  defp translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(SafiraWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(SafiraWeb.Gettext, "errors", msg, opts)
    end
  end

  defp humanize(atom) when is_atom(atom), do: humanize(Atom.to_string(atom))

  defp humanize(bin) when is_binary(bin) do
    bin =
      if String.ends_with?(bin, "_id") do
        binary_part(bin, 0, byte_size(bin) - 3)
      else
        bin
      end

    bin |> String.replace("_", " ") |> :string.titlecase()
  end
end
