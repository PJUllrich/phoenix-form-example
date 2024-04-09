defmodule FormExample.Profiles.Profile do
  alias FormExample.Businesses.Business
  use Ecto.Schema
  import Ecto.Changeset

  schema "profiles" do
    field :name, :string

    belongs_to :business, Business

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:business_id, :name])
    |> validate_required([:business_id, :name])
    |> validate_length(:name, min: 3, max: 10)
  end
end
