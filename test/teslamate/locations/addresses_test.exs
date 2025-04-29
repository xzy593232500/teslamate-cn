defmodule TeslaMate.LocationsAddressesTest do
  use TeslaMate.DataCase

  alias TeslaMate.{Locations, Repo}
  alias TeslaMate.Locations.Address

  describe "addresses" do
    @valid_attrs %{
      city: "some city",
      county: "some county",
      country: "some country",
      display_name: "some display_name",
      house_number: "some house_number",
      latitude: 20.5,
      longitude: 120.5,
      name: "some name",
      neighbourhood: "some neighbourhood",
      osm_id: 42,
      osm_type: "way",
      postcode: "some postcode",
      raw: %{},
      road: "some road",
      state: "some state",
      state_district: "some state_district"
    }
    @update_attrs %{
      city: "some updated city",
      county: "some updated county",
      country: "some updated country",
      display_name: "some updated display_name",
      house_number: "some updated house_number",
      latitude: -20.7,
      longitude: -112.7,
      name: "some updated name",
      neighbourhood: "some updated neighbourhood",
      osm_id: 43,
      osm_type: "road",
      postcode: "some updated postcode",
      raw: %{},
      road: "some updated road",
      state: "some updated state",
      state_district: "some updated state_district"
    }
    @invalid_attrs %{
      city: nil,
      county: nil,
      country: nil,
      display_name: nil,
      house_number: nil,
      latitude: nil,
      longitude: nil,
      name: nil,
      neighbourhood: nil,
      osm_id: nil,
      osm_type: nil,
      postcode: nil,
      raw: nil,
      road: nil,
      state: nil,
      state_district: nil
    }

    def address_fixture(attrs \\ %{}) do
      {:ok, address} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Locations.create_address()

      address
    end

    test "create_address/1 with valid data creates a address" do
      assert {:ok, %Address{} = address} = Locations.create_address(@valid_attrs)
      assert address.city == "some city"
      assert address.county == "some county"
      assert address.country == "some country"
      assert address.display_name == "some display_name"
      assert address.house_number == "some house_number"
      assert address.latitude == Decimal.new("20.500000")
      assert address.longitude == Decimal.new("120.500000")
      assert address.name == "some name"
      assert address.neighbourhood == "some neighbourhood"
      assert address.osm_id == 42
      assert address.osm_type == "way"
      assert address.postcode == "some postcode"
      assert address.raw == %{}
      assert address.road == "some road"
      assert address.state == "some state"
      assert address.state_district == "some state_district"
    end

    test "create_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{} = changeset} = Locations.create_address(@invalid_attrs)

      assert errors_on(changeset) == %{
               display_name: ["can't be blank"],
               latitude: ["can't be blank"],
               longitude: ["can't be blank"],
               osm_id: ["can't be blank"],
               osm_type: ["can't be blank"],
               raw: ["can't be blank"]
             }
    end

    test "update_address/2 with valid data updates the address" do
      address = address_fixture()
      assert {:ok, %Address{} = address} = Locations.update_address(address, @update_attrs)
      assert address.city == "some updated city"
      assert address.county == "some updated county"
      assert address.country == "some updated country"
      assert address.display_name == "some updated display_name"
      assert address.house_number == "some updated house_number"
      assert address.latitude == Decimal.new("-20.700000")
      assert address.longitude == Decimal.new("-112.700000")
      assert address.name == "some updated name"
      assert address.neighbourhood == "some updated neighbourhood"
      assert address.osm_id == 43
      assert address.osm_type == "road"
      assert address.postcode == "some updated postcode"
      assert address.raw == %{}
      assert address.road == "some updated road"
      assert address.state == "some updated state"
      assert address.state_district == "some updated state_district"
    end

    test "update_address/2 with invalid data returns error changeset" do
      address = address_fixture()
      assert {:error, %Ecto.Changeset{}} = Locations.update_address(address, @invalid_attrs)
    end
  end

  describe "find_address/1 " do
    test "looks up and creates a new address based on high accuracy mock data" do
      # Mocking GeocoderMock to return specific data for known coordinates
      expect(GeocoderMock, :reverse_lookup, fn lat, lon, lang ->
        case {lat, lon} do
          {52.019596, 8.526318} ->
            {:ok,
             %{
               city: "Bielefeld",
               country: "Germany",
               county: nil,
               display_name:
                 "Von-der-Recke-Straße, Mitte, Bielefeld, Regierungsbezirk Detmold, Nordrhein-Westfalen, 33602, Deutschland",
               house_number: nil,
               latitude: "52.0196010141104",
               longitude: "8.52631835353143",
               name: "Von-der-Recke-Straße",
               neighbourhood: "Mitte",
               osm_id: 103_619_766,
               osm_type: "way",
               postcode: "33602",
               raw: %{
                 "city" => "Bielefeld",
                 "country" => "Deutschland",
                 "country_code" => "de",
                 "postcode" => "33602",
                 "road" => "Von-der-Recke-Straße",
                 "state" => "Nordrhein-Westfalen",
                 "state_district" => "Regierungsbezirk Detmold",
                 "suburb" => "Mitte"
               },
               road: "Von-der-Recke-Straße",
               state: "Nordrhein-Westfalen",
               state_district: nil
             }}

          {52.394246, 13.542552} ->
            {:ok,
             %{
               city: nil,
               country: "Germany",
               county: nil,
               display_name:
                 "Tesla Store & Service Center Berlin, 24-26, Alexander-Meißner-Straße, Altglienicke, Treptow-Köpenick, Berlin, 12526, Germany",
               house_number: "24-26",
               latitude: "52.3941049",
               longitude: "13.5425707",
               name: "Tesla Store & Service Center Berlin",
               neighbourhood: "Altglienicke",
               osm_id: 64_445_009,
               osm_type: "way",
               postcode: "12526",
               raw: %{
                 "car" => "Tesla Store & Service Center Berlin",
                 "city_district" => "Treptow-Köpenick",
                 "country" => "Germany",
                 "country_code" => "de",
                 "house_number" => "24-26",
                 "postcode" => "12526",
                 "road" => "Alexander-Meißner-Straße",
                 "state" => "Berlin",
                 "suburb" => "Altglienicke"
               },
               road: "Alexander-Meißner-Straße",
               state: "Berlin",
               state_district: nil
             }}

          _ ->
            {:error, :not_found}
        end
      end)

      assert {:ok, %Address{} = address} =
               Locations.find_address(%{latitude: 52.019596, longitude: 8.526318})

      assert address.osm_id == 103_619_766
      assert address.city == "Bielefeld"

      assert [maddress] = Repo.all(Address)
      assert address == maddress

      assert {:ok, %Address{} = ^address} =
               Locations.find_address(%{latitude: 52.394246, longitude: 13.542552})

      assert [^address] = Repo.all(Address)
    end

    test "handles an unknown address by creating one with default values" do
      expect(GeocoderMock, :reverse_lookup, fn _, _, _ -> {:error, :unknown} end)

      assert {:ok, %Address{} = address} =
               Locations.find_address(%{latitude: 0, longitude: 0})

      assert address.osm_id == 0
      assert address.osm_type == "unknown"
      assert address.display_name == "Unknown"
      assert address.latitude == Decimal.new("0.0")
      assert address.longitude == Decimal.new("0.0")

      assert [maddress] = Repo.all(Address)
      assert address == maddress
    end
  end
end