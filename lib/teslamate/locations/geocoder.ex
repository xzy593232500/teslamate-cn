defmodule TeslaMate.Locations.Geocoder do
  use Tesla, only: [:get]

  @version Mix.Project.config()[:version]
  @amap_api_key Application.compile_env!(:teslamate, :amap_api_key)

  adapter Tesla.Adapter.Finch, name: TeslaMate.HTTP, receive_timeout: 30_000

  plug Tesla.Middleware.BaseUrl, "https://restapi.amap.com"
  plug Tesla.Middleware.Headers, [{"user-agent", "TeslaMate/#{@version}"}]
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Logger, debug: true, log_level: &log_level/1

  alias TeslaMate.Locations.Address

  def reverse_lookup(lat, lon, lang \\ "zh-CN") do
    opts = [
      location: "#{lon},#{lat}",
      output: "json",
      key: @amap_api_key,
      extensions: "all"
    ]

    with {:ok, address_raw} <- query("/v3/geocode/regeo", lang, opts),
         {:ok, address} <- into_address(address_raw) do
      {:ok, address}
    end
  end

  def details(addresses, lang) when is_list(addresses) do
    addresses
    |> Enum.map(fn %Address{} = address ->
      case reverse_lookup(address.latitude, address.longitude, lang) do
        {:ok, attrs} -> {:ok, {address, attrs}}
        {:error, reason} -> {:error, {address, reason}}
      end
    end)
    |> Enum.reduce([], fn
      {:ok, {address, attrs}}, acc -> [{address, attrs} | acc]
      {:error, {address, reason}}, acc -> [{address, nil} | acc]
    end)
    |> Enum.reverse()
  end

  defp query(url, lang, params) do
    case get(url, query: params, headers: [{"Accept-Language", lang}]) do
      {:ok, %Tesla.Env{status: 200, body: %{"regeocode" => regeocode}}} ->
        {:ok, regeocode}

      {:ok, %Tesla.Env{body: %{"info" => "OK"}}} ->
        {:ok, %{}}

      {:ok, %Tesla.Env{body: %{"info" => reason}}} ->
        {:error, reason}

      {:ok, %Tesla.Env{} = env} ->
        {:error, reason: "Unexpected response", env: env}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Address Formatting
  # Source: https://lbs.amap.com/api/webservice/guide/api/georegeo/

  defp into_address(%{"formatted_address" => formatted_address, "addressComponent" => address_component}) do
    address = %{
      display_name: formatted_address,
      osm_id: nil,
      osm_type: nil,
      latitude: Decimal.new(address_component["location"] |> String.split(",") |> Enum.at(1)),
      longitude: Decimal.new(address_component["location"] |> String.split(",") |> Enum.at(0)),
      name: Map.get(address_component, "building"),
      house_number: Map.get(address_component, "number"),
      road: Map.get(address_component, "street"),
      neighbourhood: Map.get(address_component, "neighborhood"),
      city: Map.get(address_component, "city"),
      county: Map.get(address_component, "district"),
      postcode: Map.get(address_component, "adcode"),
      state: Map.get(address_component, "province"),
      state_district: Map.get(address_component, "township"),
      country: "China",
      raw: %{}
    }

    {:ok, struct(Address, address)}
  end

  defp into_address(_raw) do
    unknown_address = %{
      display_name: "Unknown",
      osm_id: 0,
      osm_type: "unknown",
      latitude: 0.0,
      longitude: 0.0,
      raw: %{}
    }

    {:ok, struct(Address, unknown_address)}
  end

  defp log_level(%Tesla.Env{} = env) when env.status >= 400, do: :warning
  defp log_level(%Tesla.Env{}), do: :info
end