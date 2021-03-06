defmodule Margaret.Tags do
  @moduledoc """
  The Tags context.
  """

  import Ecto.Query

  alias Margaret.Repo
  alias Margaret.Tags.Tag

  @doc """
  Gets a tag by its id.

  ## Examples

      iex> get_tag(123)
      %Tag{}

      iex> get_tag(456)
      nil

  """
  @spec get_tag(term) :: Tag.t | nil
  def get_tag(id), do: Repo.get(Tag, id)

  @doc """
  Gets a tag by its id.

  Raises `Ecto.NoResultsError` if the tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  def get_tag_by_name(name), do: Repo.get_by(Tag, name: name)

  @doc """
  Creates a tag.
  """
  def create_tag(attrs) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Inserts all the tags that weren't persisted and
  gets all the tags from the `tags` list.

  ## Examples

      iex> insert_and_get_all_tags(["programming", "elixir"])
      [%Tag{title: "programming"}, %Tag{title: "elixir"}]

      iex> get_tag([])
      []

  """
  @spec insert_and_get_all_tags([String.t]) :: [%Tag{}]
  def insert_and_get_all_tags([]), do: []

  def insert_and_get_all_tags(tags) when is_list(tags) do
    structs =
      tags
      |> Stream.map(&String.trim/1)
      |> Stream.map(&(%{title: &1}))
      |> Stream.map(&Map.put(&1, :inserted_at, NaiveDateTime.utc_now()))
      |> Enum.map(&Map.put(&1, :updated_at, NaiveDateTime.utc_now()))

    Repo.insert_all(Tag, structs, on_conflict: :nothing)

    query = from t in Tag,
      where: t.title in ^tags

    Repo.all(query)
  end
end
