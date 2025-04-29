defmodule TeslaMate.Locations.GeocoderTest do
  use ExUnit.Case, async: false

  alias TeslaMate.Locations.Geocoder

  import Mock

  defp geocoder_mock(lat, lon, body) do
    {Tesla.Adapter.Finch, [],
     call: fn %Tesla.Env{} = env, _opts ->
       assert env.url == "https://restapi.amap.com/v3/geocode/regeo"

       assert env.query == [
                {:key, "2d1ed9b1ca40da3dd0449d90bf0bf9b0"},
                {:location, "#{lon},#{lat}"},
                {:extensions, "all"}
              ]

       env = %Tesla.Env{
         body: Jason.encode!(body),
         headers: [{"content-type", "application/json"}],
         status: 200
       }

       {:ok, env}
     end}
  end

  test "does a reverse lookup of the given coordinates" do
    with_mocks [
      geocoder_mock(39.990464, 116.481488, %{
        "status" => "1",
        "regeocode" => %{
          "formatted_address" => "北京市朝阳区望京街道阜通东大街6号",
          "addressComponent" => %{
            "province" => "北京市",
            "city" => "北京市",
            "district" => "朝阳区",
            "township" => "望京街道",
            "streetNumber" => %{
              "street" => "阜通东大街",
              "number" => "6号"
            }
          }
        }
      })
    ] do
      assert Geocoder.reverse_lookup(39.990464, 116.481488) ==
               {:ok,
                %{
                  city: "北京市",
                  country: "中国",
                  county: "朝阳区",
                  display_name: "北京市朝阳区望京街道阜通东大街6号",
                  house_number: "6号",
                  latitude: 39.990464,
                  longitude: 116.481488,
                  name: "望京街道",
                  neighbourhood: "望京街道",
                  osm_id: 0,
                  osm_type: "amap",
                  postcode: "",
                  road: "阜通东大街",
                  state: "北京市",
                  state_district: nil,
                  raw: %{
                    "province" => "北京市",
                    "city" => "北京市",
                    "district" => "朝阳区",
                    "township" => "望京街道",
                    "streetNumber" => %{"street" => "阜通东大街", "number" => "6号"}
                  }
                }}
    end
  end

  test "returns a dummy address if the location cannot be geocoded" do
    with_mock Tesla.Adapter.Finch,
      call: fn %Tesla.Env{} = env, _opts ->
        assert env.url == "https://restapi.amap.com/v3/geocode/regeo"

        assert env.query == [
                 {:key, "2d1ed9b1ca40da3dd0449d90bf0bf9b0"},
                 {:location, "116.481488,39.990464"},
                 {:extensions, "all"}
               ]

        {:ok, %Tesla.Env{body: Jason.encode!(%{"status" => "0", "info" => "INVALID_USER_KEY"}), headers: [], status: 200}}
      end do
      assert Geocoder.reverse_lookup(39.990464, 116.481488) ==
               {:error, {:geocoding_failed, "INVALID_USER_KEY"}}
    end
  end

  test "handles errors" do
    with_mock Tesla.Adapter.Finch,
      call: fn %Tesla.Env{} = env, _opts ->
        assert env.url == "https://restapi.amap.com/v3/geocode/regeo"

        assert env.query == [
                 {:key, "2d1ed9b1ca40da3dd0449d90bf0bf9b0"},
                 {:location, "116.481488,39.990464"},
                 {:extensions, "all"}
               ]

        {:ok, %Tesla.Env{body: Jason.encode!(%{"status" => "0", "info" => "SERVICE_NOT_EXIST"}), headers: [], status: 200}}
      end do
      assert Geocoder.reverse_lookup(39.990464, 116.481488) ==
               {:error, {:geocoding_failed, "SERVICE_NOT_EXIST"}}
    end
  end
end