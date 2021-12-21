# typed: true
require 'easypostdevtools/random'

class Constants
  CUSTOMS_ITEMS_JSON = "json/customs_items.json"
  CUSTOMS_INFO_JSON = "json/customs_info.json"
  CARRIERS_JSON = "json/carriers.json"
  LABEL_OPTIONS_JSON = "json/label_options.json"
  TRACKERS_JSON = "json/trackers.json"
  OPTIONS_JSON = "json/options.json"
  PICKUPS_JSON = "json/pickups.json"

  class JsonFile
    extend T::Sig
    private @file_name = ""
    private @parent_folder = ""

    sig { params(file_name: String, parent_folder: String).void }
    public def initialize(file_name, parent_folder)
      @file_name = file_name
      @parent_folder = parent_folder
    end

    sig { returns(String) }
    public def json_path
      @parent_folder + "/" + @file_name + ".min.json"
    end
  end

  class JsonAddressFile < JsonFile
    extend T::Sig
    sig { params(abbreviation: String, parent_folder: String).void }
    public def initialize(abbreviation, parent_folder)
      super(abbreviation, parent_folder)
    end

    sig { returns(String) }
    public def address_file
      "json/addresses/" + self.json_path
    end
  end

  class Addresses
    extend T::Sig

    class Country
      extend T::Sig

      class COUNTRY
        UNITED_STATES = JsonAddressFile.new("US", "united_states")
        CANADA = JsonAddressFile.new("BC", "canada")
        CHINA = JsonAddressFile.new("BJ", "china")
        HONG_KONG = JsonAddressFile.new("HK", "china")
        UNITED_KINGDOM = JsonAddressFile.new("UK", "europe")
        GERMANY = JsonAddressFile.new("DE", "europe")
        SPAIN = JsonAddressFile.new("ES", "europe")
        MEXICO = JsonAddressFile.new("MX", "mexico")
        AUSTRALIA = JsonAddressFile.new("VT", "australia")
      end

      sig { returns(T::Array[JsonAddressFile]) }
      public def values
        [COUNTRY::UNITED_STATES, COUNTRY::CANADA, COUNTRY::CHINA, COUNTRY::HONG_KONG, COUNTRY::UNITED_KINGDOM, COUNTRY::GERMANY, COUNTRY::SPAIN, COUNTRY::MEXICO, COUNTRY::AUSTRALIA]
      end

      sig { returns(Integer) }
      public def amount
        values.length
      end

      sig { returns(T::Array[JsonAddressFile]) }
      public def all
        values
      end

      sig { returns(T.nilable(JsonAddressFile)) }
      public def random
        item = values.sample
        if item.nil?
          raise "No countries"
        end
        if item.is_a?(Array)
          item[0]
        end
        item
      end
    end

    class State
      extend T::Sig

      class STATE
        ARIZONA = JsonAddressFile.new("AZ", "united_states")
        CALIFORNIA = JsonAddressFile.new("CA", "united_states")
        IDAHO = JsonAddressFile.new("ID", "united_states")
        KANSAS = JsonAddressFile.new("KS", "united_states")
        NEVADA = JsonAddressFile.new("NV", "united_states")
        NEW_YORK = JsonAddressFile.new("NY", "united_states")
        OREGON = JsonAddressFile.new("OR", "united_states")
        TEXAS = JsonAddressFile.new("TX", "united_states")
        UTAH = JsonAddressFile.new("UT", "united_states")
        WASHINGTON = JsonAddressFile.new("WA", "united_states")
      end

      sig { returns(T::Array[JsonAddressFile]) }
      public def values
        [STATE::ARIZONA, STATE::CALIFORNIA, STATE::IDAHO, STATE::KANSAS, STATE::NEVADA, STATE::NEW_YORK, STATE::OREGON, STATE::TEXAS, STATE::UTAH, STATE::WASHINGTON]
      end

      sig { returns(Integer) }
      public def amount
        values.length
      end

      sig { returns(T::Array[JsonAddressFile]) }
      public def all
        values
      end

      sig { returns(JsonAddressFile) }
      public def random
        item = values.sample
        if item.nil?
          raise "No states"
        end
        if item.is_a?(Array)
          item[0]
        end
        item
      end
    end

    sig { returns(String) }
    public def get_random_country_address_file
      country = Country.new.random
      if country.nil?
        raise "No country found"
      end
      country.address_file
    end

    sig { returns(String) }
    public def get_random_state_address_file
      state = State.new.random
      state.address_file
    end

    sig { params(country: T.nilable(JsonAddressFile), state: T.nilable(JsonAddressFile)).returns(String) }
    public def get_random_address_file(country, state)
      unless country.nil?
        country.address_file
      end
      unless state.nil?
        state.address_file
      end
      if Random.new.get_random_boolean == true
        get_random_country_address_file
      else
        get_random_state_address_file
      end
    end
  end
end
