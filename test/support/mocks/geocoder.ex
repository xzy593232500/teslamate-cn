defmodule GeocoderMock do
  alias TeslaMate.Locations.Address

  def reverse_lookup(%Decimal{} = lat, %Decimal{} = lon, lang) do
    reverse_lookup(Decimal.to_float(lat), Decimal.to_float(lon), lang)
  end

  def reverse_lookup(99.9, 99.9, _lang) do
    {:error, :induced_error}
  end

  def reverse_lookup(-99.9, -99.9, _lang) do
    {:ok,
     %{
       display_name: "Unknown",
       osm_type: "unknown",
       osm_id: 0,
       latitude: 0.0,
       longitude: 0.0,
       raw: %{"error" => "Unable to geocode"}
     }}
  end

  def reverse_lookup(lat, lon, _lang) when is_number(lat) and is_number(lon) do
    {wgs_lng, wgs_lat} = gcj02_to_wgs84(lon, lat)

    {:ok,
     %{
       city: "示例城市",
       country: "中国",
       county: nil,
       display_name: "示例道路, 示例城市, 示例省份, 中国",
       house_number: "88号",
       latitude: "#{wgs_lat}",
       longitude: "#{wgs_lng}",
       name: "示例建筑",
       neighbourhood: "示例街道",
       osm_id: 0,
       osm_type: "amap",
       postcode: "100000",
       raw: %{
         "province" => "示例省份",
         "city" => "示例城市",
         "district" => "示例区",
         "township" => "示例街道",
         "street" => "示例道路",
         "street_number" => "88号"
       },
       road: "示例道路",
       state: "示例省份",
       state_district: nil
     }}
  end

  def details(addresses, lang) do
    {:ok,
     Enum.map(addresses, fn
       %Address{display_name: "error"} ->
         throw({:error, :boom})

       %Address{} = address ->
         address
         |> Map.from_struct()
         |> Map.update(:name, "", fn val -> "#{val}_#{lang}" end)
         |> Map.update(:state, "", fn val -> "#{val}_#{lang}" end)
         |> Map.update(:country, "", fn _ -> "中国" end)
     end)}
  catch
    {:error, :boom} ->
      {:error, :boom}
  end

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
end