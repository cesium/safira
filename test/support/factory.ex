defmodule MyApp.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Safira.Repo

  # without Ecto
  use ExMachina

  def user_factory do
    %MyApp.User{
      name: "Jane Smith",
      email: sequence(:email, &"email-#{&1}@example.com"),
      password_hash: :crypto.strong_rand_bytes(64) |> Base.url_encode64 |> binary_part(0, 64)
    }
  end

  def badge_factory do
    title = sequence(:title, &"Use ExMachina! (Part #{&1})")
    # derived attribute
    slug = MyApp.Article.title_to_slug(title)
    %MyApp.Article{
      title: title,
      slug: slug,
      # associations are inserted when you call `insert`
      author: build(:user),
    }
  end

  def article_factory do
    title = sequence(:title, &"Use ExMachina! (Part #{&1})")
    # derived attribute
    slug = MyApp.Article.title_to_slug(title)
    %MyApp.Article{
      title: title,
      slug: slug,
      # associations are inserted when you call `insert`
      author: build(:user),
    }
  end

  # derived factory
  def featured_article_factory do
    struct!(
      article_factory(),
      %{
        featured: true,
      }
    )
  end

  def comment_factory do
    %MyApp.Comment{
      text: "It's great!",
      article: build(:article),
    }
  end
end

