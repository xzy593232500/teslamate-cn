defmodule TeslaMate.Locations.Geocoder do
  use Tesla, only: [:get]

  @amap_key "2d1ed9b1ca40da3dd0449d90bf0bf9b0"

  adapter Tesla.Adapter.Finch, name: TeslaMate.HTTP, receive_timeout: 30_000

  plug Tesla.Middleware.BaseUrl, "https://restapi.amap.com"
  plug Tesla.Middleware.Headers, [{"user-agent", "TeslaMate-Geocoder"}]
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Logger, debug: true, log_level: &log_level/1

  alias TeslaMate.Locations.Address

  def reverse_lookup(lat, lon, _lang \\ "zh_cn") do
    params = [
      key: @amap_key,
      location: "#{lon},#{lat}",
      extensions: "all"
    ]

    with {:ok, address_raw} <- query("/v3/geocode/regeo", params),
         {:ok, address} <- into_address(address_raw, lat, lon) do
      {:ok, address}
    end
  end

  def details(addresses, _lang) when is_list(addresses) do
    {:ok, addresses}
  end

  defp query(url, params) do
    case get(url, query: params) do
      {:ok, %Tesla.Env{status: 200, body: %{"status" => "1"} = body}} -> {:ok, body}
      {:ok, %Tesla.Env{body: body}} -> {:error, {:geocoding_failed, body}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp into_address(%{"regeocode" => %{"addressComponent" => address_component, "formatted_address" => formatted}}, orig_lat, orig_lon) do
    {lng, lat} = gcj02_to_wgs84(orig_lon, orig_lat)

    address = %{
      display_name: formatted,
      osm_id: 0,
      osm_type: "amap",
      latitude: lat,
      longitude: lng,
      name: Map.get(address_component, "building") || Map.get(address_component, "neighborhood") || Map.get(address_component, "township"),
      house_number: Map.get(address_component, "streetNumber") |> Map.get("number"),
      road: Map.get(address_component, "streetNumber") |> Map.get("street"),
      neighbourhood: Map.get(address_component, "neighborhood"),
      city: Map.get(address_component, "city") || Map.get(address_component, "district"),
      county: Map.get(address_component, "district"),
      postcode: Map.get(address_component, "adcode"),
      state: Map.get(address_component, "province"),
      state_district: nil,
      country: "中国",
      raw: address_component
    }

    {:ok, address}
  end

  defp into_address(%{"status" => "0", "info" => info}, _lat, _lon) do
    {:error, {:geocoding_failed, info}}
  end

  # GCJ-02 -> WGS-84 逆变换
  @pi 3.14159265358979323846
  @a 6378245.0
  @ee 0.00669342162296594323

  defp gcj02_to_wgs84(lng, lat) do
    if out_of_china(lng, lat) do
      {lng, lat}
    else
      {dlat, dlng} = delta(lng, lat)
      {lng - dlng, lat - dlat}
    end
  end

  defp out_of_china(lng, lat) do
    lng < 72.004 or lng > 137.8347 or lat < 0.8293 or lat > 55.8271
  end

  defp delta(lng, lat) do
    dlat = transform_lat(lng - 105.0, lat - 35.0)
    dlng = transform_lng(lng - 105.0, lat - 35.0)
    radlat = lat / 180.0 * @pi
    magic = :math.sin(radlat)
    magic = 1 - @ee * magic * magic
    sqrtmagic = :math.sqrt(magic)
    dlat = (dlat * 180.0) / ((@a * (1 - @ee)) / (magic * sqrtmagic) * @pi)
    dlng = (dlng * 180.0) / (@a / sqrtmagic * :math.cos(radlat) * @pi)
    {dlat, dlng}
  end

  defp transform_lat(x, y) do
    ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * :math.sqrt(abs(x))
    ret = ret + (20.0 * :math.sin(6.0 * x * @pi) + 20.0 * :math.sin(2.0 * x * @pi)) * 2.0 / 3.0
    ret = ret + (20.0 * :math.sin(y * @pi) + 40.0 * :math.sin(y / 3.0 * @pi)) * 2.0 / 3.0
    ret = ret + (160.0 * :math.sin(y / 12.0 * @pi) + 320 * :math.sin(y * @pi / 30.0)) * 2.0 / 3.0
    ret
  end

  defp transform_lng(x, y) do
    ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * :math.sqrt(abs(x))
    ret = ret + (20.0 * :math.sin(6.0 * x * @pi) + 20.0 * :math.sin(2.0 * x * @pi)) * 2.0 / 3.0
    ret = ret + (20.0 * :math.sin(x * @pi) + 40.0 * :math.sin(x / 3.0 * @pi)) * 2.0 / 3.0
    ret = ret + (150.0 * :math.sin(x / 12.0 * @pi) + 300.0 * :math.sin(x / 30.0 * @pi)) * 2.0 / 3.0
    ret
  end

  defp log_level(%Tesla.Env{} = env) when env.status >= 400, do: :warning
  defp log_level(%Tesla.Env{}), do: :info
end
