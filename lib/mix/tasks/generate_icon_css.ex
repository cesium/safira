defmodule Mix.Tasks.GenerateIconCss do
  @moduledoc """
  Generates ALL CSS variables and utility classes for Heroicons and FontAwesome icons.
  """
  use Mix.Task

  @shortdoc "Generates icon CSS variables and utilities"

  def run(_args) do
    Mix.shell().info("🔍 Generating icon CSS...")

    heroicons = generate_heroicons()
    fontawesome = generate_fontawesome()

    variables_css =
      "/* Auto-generated icon CSS variables - DO NOT EDIT MANUALLY */\n\n" <>
        "/* Heroicons */\n:root {\n" <>
        Enum.join(heroicons.variables, "\n") <>
        "\n}\n\n" <>
        "/* FontAwesome */\n:root {\n" <>
        Enum.join(fontawesome.variables, "\n") <>
        "\n}\n"

    utilities_css =
      "/* Auto-generated icon utility classes - DO NOT EDIT MANUALLY */\n\n" <>
        Enum.join(heroicons.utilities, "\n\n") <>
        "\n\n" <>
        Enum.join(fontawesome.utilities, "\n\n") <>
        "\n"

    File.write!("assets/css/icons.css", variables_css)
    File.write!("assets/css/icons-utilities.css", utilities_css)

    total = length(heroicons.variables) + length(fontawesome.variables)
    Mix.shell().info("✨ Generated #{total} icons")
    Mix.shell().info("   - assets/css/icons.css")
    Mix.shell().info("   - assets/css/icons-utilities.css")
  end

  defp encode_svg(content) do
    content
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
    |> URI.encode()
  end

  defp generate_utility_class(prefix, name, size) do
    ".#{prefix}-#{name} {\n" <>
      "  mask-image: var(--#{prefix}-#{name});\n" <>
      "  -webkit-mask-image: var(--#{prefix}-#{name});\n" <>
      "  mask-repeat: no-repeat;\n" <>
      "  -webkit-mask-repeat: no-repeat;\n" <>
      "  mask-position: center;\n" <>
      "  -webkit-mask-position: center;\n" <>
      "  mask-size: contain;\n" <>
      "  -webkit-mask-size: contain;\n" <>
      "  background-color: currentColor;\n" <>
      "  display: inline-block;\n" <>
      "  width: #{size};\n" <>
      "  height: #{size};\n" <>
      "}"
  end

  defp generate_heroicons do
    base_dir = "deps/heroicons/optimized"

    if !File.exists?(base_dir) do
      Mix.shell().info("⚠️  Heroicons not found")
      %{variables: [], utilities: []}
    else
      variants = [
        {"", "24/outline", "1.5rem"},
        {"-solid", "24/solid", "1.5rem"},
        {"-mini", "20/solid", "1.25rem"},
        {"-micro", "16/solid", "1rem"}
      ]

      Mix.shell().info("🎨 Processing Heroicons...")

      {variables, utilities} =
        Enum.flat_map(variants, fn {suffix, dir, size} ->
          full_dir = Path.join(base_dir, dir)

          if File.exists?(full_dir) do
            {:ok, files} = File.ls(full_dir)
            svg_files = Enum.filter(files, &String.ends_with?(&1, ".svg"))
            Mix.shell().info("  Found #{length(svg_files)} icons in #{dir}")

            Enum.map(svg_files, fn file ->
              name = Path.basename(file, ".svg") <> suffix
              {:ok, content} = File.read(Path.join(full_dir, file))
              encoded = encode_svg(content)

              variable = "  --hero-#{name}: url('data:image/svg+xml;utf8,#{encoded}');"
              utility = generate_utility_class("hero", name, size)

              {variable, utility}
            end)
          else
            []
          end
        end)
        |> Enum.unzip()

      Mix.shell().info("✅ Generated #{length(variables)} Heroicon classes")
      %{variables: variables, utilities: utilities}
    end
  end

  defp generate_fontawesome do
    base_dir = "deps/fontawesome/svgs"

    if !File.exists?(base_dir) do
      Mix.shell().info("⚠️  FontAwesome not found")
      %{variables: [], utilities: []}
    else
      variants = [
        {"", "regular", "", "1.25rem"},
        {"-solid", "solid", "", "1.25rem"},
        {"", "brands", "brand-", "1.25rem"}
      ]

      Mix.shell().info("🎨 Processing FontAwesome...")

      {variables, utilities} =
        Enum.flat_map(variants, fn {suffix, dir, name_prefix, size} ->
          full_dir = Path.join(base_dir, dir)

          if File.exists?(full_dir) do
            {:ok, files} = File.ls(full_dir)
            svg_files = Enum.filter(files, &String.ends_with?(&1, ".svg"))
            Mix.shell().info("  Found #{length(svg_files)} icons in #{dir}")

            Enum.map(svg_files, fn file ->
              name = name_prefix <> Path.basename(file, ".svg") <> suffix
              {:ok, content} = File.read(Path.join(full_dir, file))
              encoded = encode_svg(content)

              variable = "  --fa-#{name}: url('data:image/svg+xml;utf8,#{encoded}');"
              utility = generate_utility_class("fa", name, size)

              {variable, utility}
            end)
          else
            []
          end
        end)
        |> Enum.unzip()

      Mix.shell().info("✅ Generated #{length(variables)} FontAwesome classes")
      %{variables: variables, utilities: utilities}
    end
  end
end
