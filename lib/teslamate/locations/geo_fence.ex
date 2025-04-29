defmodule TeslaMate.Locations.GeoFence do
  use Ecto.Schema

  import Ecto.Changeset

  schema "geofences" do
    field :name, :string
    field :latitude, :decimal, read_after_writes: true
    field :longitude, :decimal, read_after_writes: true
    field :radius, :integer

    field :billing_type, Ecto.Enum, values: [:per_kwh, :per_minute], read_after_writes: true
    field :cost_per_unit, :decimal, read_after_writes: true
    field :session_fee, :decimal, read_after_writes: true

    timestamps()
  end

  @doc false
  def changeset(geofence, attrs) do
    geofence
    |> cast(attrs, [
      :name,
      :radius,
      :latitude,
      :longitude,
      :cost_per_unit,
      :session_fee,
      :billing_type
    ])
    |> validate_required([:name, :latitude, :longitude, :radius])
    |> validate_number(:radius, greater_than: 0, less_than: 5000)
    |> validate_number(:session_fee, greater_than_or_equal_to: 0)
    |> update_change(:name, &String.trim/1)
  end
end