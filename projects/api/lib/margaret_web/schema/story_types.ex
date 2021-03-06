defmodule MargaretWeb.Schema.StoryTypes do
  @moduledoc """
  The Story GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.{Resolvers, Middleware}

  @desc """
  The publish status of a story.
  """
  enum :story_publish_status do
    value :public
    value :draft
    value :unlisted
  end

  @desc """
  The licence of a story.
  """
  enum :story_license do
    value :all_rights_reserved
    value :public_domain
  end

  @desc """
  The connection type for Story.
  """
  connection node_type: :story do
    @desc "The total count of stories."
    field :total_count, non_null(:integer)

    @desc "An edge in a connection."
    edge do end
  end

  @desc """
  A story is a post.
  """
  node object :story do
    @desc "The title of the story."
    field :title, non_null(:string)

    @desc "The body of the story."
    field :body, non_null(:string)

    @desc "The author of the story."
    field :author, non_null(:user) do
      resolve &Resolvers.Accounts.resolve_user/3
    end

    @desc "The slug of the story."
    field :slug, non_null(:string) do
      resolve &Resolvers.Stories.resolve_slug/3
    end

    @desc "The unique hash of the story."
    field :unique_hash, non_null(:string)

    @desc "The summary of the story."
    field :summary, :string

    field :publication, :publication do
      resolve &Resolvers.Stories.resolve_publication/3
    end

    field :tags, list_of(:tag) do
      resolve &Resolvers.Stories.resolve_tags/3
    end

    @desc "Identifies the date and time when the story was created."
    field :inserted_at, non_null(:naive_datetime)

    @desc "Identifies the date and time when the story was last updated."
    field :updated_at, non_null(:naive_datetime)

    @desc "The stargazers of the story."
    connection field :stargazers, node_type: :user, connection: :stargazer do
      resolve &Resolvers.Stories.resolve_stargazers/3
    end

    @desc "The comments of the story."
    connection field :comments, node_type: :comment do
      resolve &Resolvers.Stories.resolve_comments/3
    end

    @desc "Identifies the date and time when the story was published."
    field :published_at, :naive_datetime

    field :publish_status, non_null(:story_publish_status)

    field :license, non_null(:story_license)

    field :viewer_can_star, non_null(:boolean) do
      middleware Middleware.Authenticated, resolve: false
      resolve &Resolvers.Stories.resolve_viewer_can_star/3
    end

    field :viewer_has_starred, non_null(:boolean) do
      middleware Middleware.Authenticated, resolve: false
      resolve &Resolvers.Stories.resolve_viewer_has_starred/3
    end

    field :viewer_can_bookmark, non_null(:boolean) do
      middleware Middleware.Authenticated, resolve: false
      resolve &Resolvers.Stories.resolve_viewer_can_bookmark/3
    end

    field :viewer_has_bookmarked, non_null(:boolean) do
      middleware Middleware.Authenticated, resolve: false
      resolve &Resolvers.Stories.resolve_viewer_has_bookmarked/3
    end

    @desc "Check if the current viewer can comment this story."
    field :viewer_can_comment, non_null(:boolean) do
      middleware Middleware.Authenticated, resolve: false
      resolve &Resolvers.Stories.resolve_viewer_can_comment/3
    end

    @desc "Check if the current viewer can update this story."
    field :viewer_can_update, non_null(:boolean) do
      middleware Middleware.Authenticated, resolve: false
      resolve &Resolvers.Stories.resolve_viewer_can_update/3
    end

    @desc "Check if the current viewer can delete this story."
    field :viewer_can_delete, non_null(:boolean) do
      middleware Middleware.Authenticated, resolve: false
      resolve &Resolvers.Stories.resolve_viewer_can_delete/3
    end

    interfaces [:starrable, :bookmarkable, :commentable, :updatable, :deletable]
  end

  object :story_queries do
    @desc "Lookup a story by its slug."
    field :story, :story do
      arg :slug, non_null(:string)

      resolve &Resolvers.Stories.resolve_story/2
    end

    @desc "Lookup stories."
    connection field :feed, node_type: :story do
      resolve &Resolvers.Stories.resolve_feed/2
    end
  end

  object :story_mutations do
    @desc "Creates a story."
    payload field :create_story do
      input do
        field :title, non_null(:string)
        field :body, non_null(:string)
        field :summary, :string
        field :publication_id, :id
        field :tags, list_of(:string)
        field :publish_status, non_null(:story_publish_status)
        field :license, non_null(:story_license)
      end

      output do
        field :story, non_null(:story)
      end

      middleware Absinthe.Relay.Node.ParseIDs, publication_id: :publication
      resolve &Resolvers.Stories.resolve_create_story/2
    end

    @desc "Updates a story."
    payload field :update_story do
      input do
        field :story_id, non_null(:id)
        field :title, :string
        field :body, :string
        field :summary, :string
        field :publish_status, :story_publish_status
        field :license, :story_license
        field :tags, list_of(:string)
      end

      output do
        field :story, non_null(:story)
      end

      middleware Absinthe.Relay.Node.ParseIDs, story_id: :story
      resolve &Resolvers.Stories.resolve_update_story/2
    end

    @desc "Deletes a story."
    payload field :delete_story do
      input do
        field :story_id, non_null(:id)
      end

      output do
        field :story, non_null(:story)
      end

      middleware Absinthe.Relay.Node.ParseIDs, story_id: :story
      resolve &Resolvers.Stories.resolve_delete_story/2
    end
  end
end
