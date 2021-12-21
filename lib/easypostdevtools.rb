# typed: true
require 'kernel'

require 'dotenv'
require 'dotenv/load'

require "easypost"
require "easypost/address"
require "easypost/api_key"
require "easypost/batch"
require "easypost/brand"
require "easypost/carrier_account"
require "easypost/carrier_type"
require "easypost/customs_info"
require "easypost/customs_item"
require "easypost/event"
require "easypost/insurance"
require "easypost/order"
require "easypost/parcel"
require "easypost/pickup_rate"
require "easypost/pickup"
require "easypost/postage_label"
require "easypost/print_job"
require "easypost/printer"
require "easypost/rate"
require "easypost/refund"
require "easypost/report"
require "easypost/scan_form"
require "easypost/shipment"
require "easypost/tax_identifier"
require "easypost/tracker"
require "easypost/user"
require "easypost/webhook"

require_relative "easypostdevtools/version"

module EasyPostDevTools
  extend T::Sig

  class KeyType
    TEST = 1
    PRODUCTION = 2
  end

  sig { params(key: String, env_dir: String, key_type: KeyType).void }
  public def setup_key(key, env_dir, key_type)
    if key.empty?
      dotenv = Dotenv.parse(env_dir)
      case key_type
      when KeyType::TEST
        key = dotenv['EASYPOST_TEST_KEY']
      when KeyType::PRODUCTION
        key = dotenv['EASYPOST_PROD_KEY']
      else
        Kernel::raise "Invalid key type."
      end
    end
    EasyPost.api_key = key
  end

  module Mapper
    extend T::Sig

    sig { params(file_path: String, count: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    public def get_maps_from_json_file(file_path, count = 1, allow_duplicates = true)
      JSONReader.new.get_random_maps_from_json_file(file_path, count, allow_duplicates)
    end

    sig { params(file_path: String).returns(T.nilable(T::Hash[String, T.untyped])) }
    public def get_map_from_json_file(file_path)
      get_maps_from_json_file(file_path, 1, false)[0]
    end
  end

  class Addresses
    extend Mapper
    extend T::Sig

    class ADDRESS_RELATIONSHIP
      SAME_STATE = 1
      DIFFERENT_STATE = 2
      SAME_COUNTRY = 3
      DIFFERENT_COUNTRY = 4
    end

    sig { params(file_path: String).returns(T::Hash[String, T.untyped]) }
    private def get_map_from_json_file(file_path)
      Mapper.instance_method(:get_map_from_json_file).bind(self).call(file_path)
    end

    sig { params(file_path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    private def get_maps_from_json_file(file_path, amount, allow_duplicates)
      Mapper.instance_method(:get_maps_from_json_file).bind(self).call(file_path, amount, allow_duplicates)
    end

    sig { params(country: T.nilable(Constants::JsonAddressFile), state: T.nilable(Constants::JsonAddressFile)).returns(T::Hash[String, T.untyped]) }
    public def get_map(country, state)
      address_file = Constants::Addresses.new.get_random_address_file(country, state)
      get_map_from_json_file(address_file)
    end

    sig { params(country: T.nilable(Constants::JsonAddressFile), state: T.nilable(Constants::JsonAddressFile)).returns(T.nilable(EasyPost::Address)) }
    public def get(country, state)
      begin
        map = get_map(country, state)
        EasyPost::Address.create(map)
      rescue
        nil
      end
    end

    sig { params(amount: Integer).returns(T::Array[T::Hash[String, T.untyped]]) }
    public def get_maps_same_state(amount)
      state = Constants::Addresses::State.new.random
      state_address_file = state.address_file
      get_maps_from_json_file(state_address_file, amount, false)
    end

    sig { params(amount: Integer).returns(T::Array[EasyPost::Address]) }
    public def get_same_state(amount)
      begin
        map = get_maps_same_state(amount)
        EasyPost::Address.create(map)
      rescue
        []
      end
    end

    sig { params(amount: Integer).returns(T::Array[T::Hash[String, T.untyped]]) }
    public def get_maps_different_states(amount)
      if amount > Constants::Addresses::State.new.amount
        raise "Amount cannot be greater than #{Constants::Addresses::State.new.amount}."
      end
      maps = []
      states = Random.new.get_random_items_from_list(Constants::Addresses::State.new.values, amount, false)
      states.each { |state|
        maps << get_map(nil, state)
      }
      maps
    end

    sig { params(amount: Integer).returns(T::Array[EasyPost::Address]) }
    public def get_different_states(amount)
      begin
        addresses = []
        maps = get_maps_different_states(amount)
        T.must(maps).each { |map|
          addresses << EasyPost::Address.create(map)
        }
        addresses
      rescue
        []
      end
    end

    sig { params(amount: Integer).returns(T::Array[T::Hash[String, T.untyped]]) }
    public def get_maps_same_country(amount)
      country = Constants::Addresses::Country.new.random
      country_address_file = T.must(country).address_file
      get_maps_from_json_file(country_address_file, amount, false)
    end

    sig { params(amount: Integer).returns(T::Array[EasyPost::Address]) }
    public def get_same_country(amount)
      begin
        map = get_maps_same_state(amount)
        EasyPost::Address.create(map)
      rescue
        []
      end
    end

    sig { params(amount: Integer).returns(T::Array[T::Hash[String, T.untyped]]) }
    public def get_maps_different_countries(amount)
      if amount > Constants::Addresses::Country.new.amount
        raise "Amount cannot be greater than #{Constants::Addresses::Country.new.amount}."
      end
      maps = []
      countries = Random.new.get_random_items_from_list(Constants::Addresses::Country.new.values, amount, false)
      countries.each { |country|
        maps << get_map(country, nil)
      }
      maps
    end

    sig { params(amount: Integer).returns(T::Array[EasyPost::Address]) }
    public def get_different_countries(amount)
      begin
        addresses = []
        maps = get_maps_different_countries(amount)
        T.must(maps).each { |map|
          addresses << EasyPost::Address.create(map)
        }
        addresses
      rescue
        []
      end
    end

    sig { params(relationship: ADDRESS_RELATIONSHIP, amount: Integer).returns(T.nilable(T::Array[T::Hash[String, T.untyped]])) }
    public def get_maps_amount(relationship, amount)
      case relationship
      when ADDRESS_RELATIONSHIP::SAME_STATE
        get_maps_same_state(amount)
      when ADDRESS_RELATIONSHIP::DIFFERENT_STATE
        get_maps_different_states(amount)
      when ADDRESS_RELATIONSHIP::SAME_COUNTRY
        get_maps_same_country(amount)
      when ADDRESS_RELATIONSHIP::DIFFERENT_COUNTRY
        get_maps_different_countries(amount)
      else
        raise "Relationship #{relationship} is not supported."
      end
    end

    sig { params(relationship: ADDRESS_RELATIONSHIP, amount: Integer).returns(T.nilable(T::Array[EasyPost::Address])) }
    public def get_amount(relationship, amount)
      case relationship
      when ADDRESS_RELATIONSHIP::SAME_STATE
        get_same_state(amount)
      when ADDRESS_RELATIONSHIP::DIFFERENT_STATE
        get_different_states(amount)
      when ADDRESS_RELATIONSHIP::SAME_COUNTRY
        get_same_country(amount)
      when ADDRESS_RELATIONSHIP::DIFFERENT_COUNTRY
        get_different_countries(amount)
      else
        raise "Relationship #{relationship} is not supported."
      end
    end

  end

  class Parcels
    extend T::Sig

    sig { returns(T.nilable(T::Hash[String, T.untyped])) }
    public def get_map
      {
        length: Random.new.get_random_float_in_range(0.0, 100.0),
        width: Random.new.get_random_float_in_range(0.0, 100.0),
        height: Random.new.get_random_float_in_range(0.0, 100.0),
        weight: Random.new.get_random_float_in_range(0.0, 100.0)
      }
    end

    sig { returns(T.nilable(EasyPost::Parcel)) }
    public def get
      begin
        EasyPost::Parcel.create(get_map)
      rescue
        nil
      end
    end

    sig { params(id: String).returns(T.nilable(EasyPost::Parcel)) }
    public def retrieve(id)
      EasyPost::Parcel.retrieve(id)
    end
  end

  class Insurance
    extend T::Sig

    sig { params(amount: T.nilable(Float)).returns(T::Hash[Symbol, T.untyped]) }
    public def get_map(amount = nil)
      if amount.nil?
        amount = Random.new.get_random_float_in_range(0.0, 100.0)
      end
      {
        amount: amount
      }
    end

    sig { params(shipment: EasyPost::Shipment, amount: T.nilable(Float)).returns(T.nilable(EasyPost::Shipment)) }
    public def insure(shipment, amount = nil)
      begin
        insurance_map = get_map(amount)
        shipment.insure(**insurance_map)
      rescue
        nil
      end
    end

  end

  class Shipments
    extend Mapper
    extend T::Sig

    sig { params(file_path: String).returns(T::Hash[String, T.untyped]) }
    private def get_map_from_json_file(file_path)
      Mapper.instance_method(:get_map_from_json_file).bind(self).call(file_path)
    end

    sig { params(file_path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    private def get_maps_from_json_file(file_path, amount, allow_duplicates)
      Mapper.instance_method(:get_maps_from_json_file).bind(self).call(file_path, amount, allow_duplicates)
    end

    sig { params(to_address_map: T.nilable(T::Hash[String, T.untyped]), from_address_map: T.nilable(T::Hash[String, T.untyped]), parcel_map: T.nilable(T::Hash[String, T.untyped])).returns(T::Hash[String, T.untyped]) }
    public def get_map(to_address_map = nil, from_address_map = nil, parcel_map = nil)
      if to_address_map.nil? && from_address_map.nil?
        address_maps = EasyPostDevTools::Addresses.new.get_maps_different_states(2)
        to_address_map = address_maps[0]
        from_address_map = address_maps[1]
      end
      if parcel_map.nil?
        parcel_map = EasyPostDevTools::Parcels.new.get_map
      end
      {
        'to_address' => to_address_map,
        'from_address' => from_address_map,
        'parcel' => parcel_map
      }
    end

    sig { params(to_address_map: T.nilable(T::Hash[String, T.untyped]), from_address_map: T.nilable(T::Hash[String, T.untyped]), parcel_map: T.nilable(T::Hash[String, T.untyped])).returns(T::Hash[String, T.untyped]) }
    public def get_return_map(to_address_map = nil, from_address_map = nil, parcel_map = nil)
      map = get_map(to_address_map, from_address_map, parcel_map)
      map['return_address'] = true
      map
    end

    sig { params(to_address_map: T.nilable(T::Hash[String, T.untyped]), from_address_map: T.nilable(T::Hash[String, T.untyped]), parcel_map: T.nilable(T::Hash[String, T.untyped])).returns(T.nilable(EasyPost::Shipment)) }
    public def get(to_address_map = nil, from_address_map = nil, parcel_map = nil)
      begin
        map = get_map(to_address_map, from_address_map, parcel_map)
        create(map)
      rescue
        nil
      end
    end

    sig { params(to_address_map: T.nilable(T::Hash[String, T.untyped]), from_address_map: T.nilable(T::Hash[String, T.untyped]), parcel_map: T.nilable(T::Hash[String, T.untyped])).returns(T.nilable(EasyPost::Shipment)) }
    public def get_return(to_address_map = nil, from_address_map = nil, parcel_map = nil)
      begin
        map = get_return_map(to_address_map, from_address_map, parcel_map)
        create(map)
      rescue
        nil
      end
    end

    sig { params(shipment_map: T::Hash[String, T.untyped]).returns(T.nilable(EasyPost::Shipment)) }
    public def create(shipment_map)
      begin
        EasyPost::Shipment.create(**shipment_map)
      rescue
        nil
      end
    end

    sig { params(shipment: EasyPost::Shipment, amount: T.nilable(Float)).returns(T.nilable(EasyPost::Shipment)) }
    public def add_insurance(shipment, amount = nil)
      begin
        insurance_map = EasyPostDevTools::Insurance.new.get_map(amount)
        shipment.insure(insurance_map)
        shipment
      rescue
        nil
      end
    end

    sig { params(shipment: EasyPost::Shipment).returns(T.nilable(EasyPost::Shipment)) }
    public def refund(shipment)
      begin
        shipment.refund
      rescue
        nil
      end
    end

    sig { params(shipment_map: T::Hash[String, T.untyped]).returns(T::Hash[String, T.untyped]) }
    public def mark_for_return(shipment_map)
      shipment_map['is_return'] = true
      shipment_map
    end
  end

  class Options
    extend Mapper
    extend T::Sig

    sig { params(file_path: String).returns(T::Hash[String, T.untyped]) }
    private def get_map_from_json_file(file_path)
      Mapper.instance_method(:get_map_from_json_file).bind(self).call(file_path)
    end

    sig { params(file_path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    private def get_maps_from_json_file(file_path, amount, allow_duplicates)
      Mapper.instance_method(:get_maps_from_json_file).bind(self).call(file_path, amount, allow_duplicates)
    end

    sig { returns(T.nilable(T::Hash[String, T.untyped])) }
    public def get_map
      get_map_from_json_file(Constants::OPTIONS_JSON)
    end

  end

  class Rates
    extend Mapper
    extend T::Sig

    sig { params(file_path: String).returns(T::Hash[String, T.untyped]) }
    private def get_map_from_json_file(file_path)
      Mapper.instance_method(:get_map_from_json_file).bind(self).call(file_path)
    end

    sig { params(file_path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    private def get_maps_from_json_file(file_path, amount, allow_duplicates)
      Mapper.instance_method(:get_maps_from_json_file).bind(self).call(file_path, amount, allow_duplicates)
    end

    sig { params(shipment_map: T.nilable(T::Hash[String, T.untyped]), shipment: T.nilable(EasyPost::Shipment)).returns(T.nilable(T::Array[EasyPost::Rate])) }
    public def get(shipment_map = nil, shipment = nil)
      begin
        if shipment.nil?
          if shipment_map.nil?
            shipment_map = EasyPostDevTools::Shipments.new.get_map(nil, nil)
          end
          shipment = EasyPost::Shipment.create(**shipment_map)
        end
        shipment = shipment.get_rates
        shipment.rates
      rescue
        nil
      end
    end
  end

  class Smartrates
    extend Mapper
    extend T::Sig

    sig { params(file_path: String).returns(T::Hash[String, T.untyped]) }
    private def get_map_from_json_file(file_path)
      Mapper.instance_method(:get_map_from_json_file).bind(self).call(file_path)
    end

    sig { params(file_path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    private def get_maps_from_json_file(file_path, amount, allow_duplicates)
      Mapper.instance_method(:get_maps_from_json_file).bind(self).call(file_path, amount, allow_duplicates)
    end

    sig { params(shipment_map: T.nilable(T::Hash[String, T.untyped]), shipment: T.nilable(EasyPost::Shipment)).returns(T.nilable(T::Array[EasyPost::Rate])) }
    public def get(shipment_map = nil, shipment = nil)
      begin
        if shipment.nil?
          if shipment_map.nil?
            shipment_map = EasyPostDevTools::Shipments.new.get_map(nil, nil)
          end
          shipment = EasyPost::Shipment.create(**shipment_map)
        end
        shipment.get_smartrates
      rescue
        nil
      end
    end
  end

  class TaxIdentifiers
    extend Mapper
    extend T::Sig

    sig { params(file_path: String).returns(T::Hash[String, T.untyped]) }
    private def get_map_from_json_file(file_path)
      Mapper.instance_method(:get_map_from_json_file).bind(self).call(file_path)
    end

    sig { params(file_path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    private def get_maps_from_json_file(file_path, amount, allow_duplicates)
      Mapper.instance_method(:get_maps_from_json_file).bind(self).call(file_path, amount, allow_duplicates)
    end

    # TODO
  end

  class Trackers
    extend Mapper
    extend T::Sig

    sig { params(file_path: String).returns(T::Hash[String, T.untyped]) }
    private def get_map_from_json_file(file_path)
      Mapper.instance_method(:get_map_from_json_file).bind(self).call(file_path)
    end

    sig { params(file_path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    private def get_maps_from_json_file(file_path, amount, allow_duplicates)
      Mapper.instance_method(:get_maps_from_json_file).bind(self).call(file_path, amount, allow_duplicates)
    end

    sig { returns(T.nilable(T::Hash[String, T.untyped])) }
    public def get_map
      get_map_from_json_file(Constants::TRACKERS_JSON)
    end
  end

  class Batch
    extend T::Sig
  end

  class CustomsItems
    extend Mapper
    extend T::Sig

    sig { params(file_path: String).returns(T::Hash[String, T.untyped]) }
    private def get_map_from_json_file(file_path)
      Mapper.instance_method(:get_map_from_json_file).bind(self).call(file_path)
    end

    sig { params(file_path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    private def get_maps_from_json_file(file_path, amount, allow_duplicates)
      Mapper.instance_method(:get_maps_from_json_file).bind(self).call(file_path, amount, allow_duplicates)
    end

    sig { params(amount: Integer, allow_duplicates: T::Boolean).returns(T.nilable(T::Array[T::Hash[String, T.untyped]])) }
    public def get_random_customs_items_maps(amount, allow_duplicates)
      get_maps_from_json_file(Constants::CUSTOMS_ITEMS_JSON, amount, allow_duplicates)
    end

    sig { params(amount: Integer, allow_duplicates: T::Boolean).returns(T.nilable(T::Array[EasyPost::CustomsItem])) }
    public def get(amount, allow_duplicates)
      customs_items_maps = get_random_customs_items_maps(amount, allow_duplicates)
      customs_items = []
      T.must(customs_items_maps).each { |customs_items_map|
        customs_items << EasyPost::CustomsItem.create(**customs_items_map)
      }
      customs_items
    end
  end

  class CustomsInfos
    extend Mapper
    extend T::Sig

    sig { params(file_path: String).returns(T::Hash[String, T.untyped]) }
    private def get_map_from_json_file(file_path)
      Mapper.instance_method(:get_map_from_json_file).bind(self).call(file_path)
    end

    sig { params(file_path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    private def get_maps_from_json_file(file_path, amount, allow_duplicates)
      Mapper.instance_method(:get_maps_from_json_file).bind(self).call(file_path, amount, allow_duplicates)
    end

    sig { params(items_amount: Integer, allow_duplicate_items: T::Boolean).returns(T.nilable(T::Hash[String, T.untyped])) }
    public def get_map(items_amount, allow_duplicate_items)
      map = get_map_from_json_file(Constants::CUSTOMS_INFO_JSON)
      T.must(map)['custom_items'] = CustomsItems.new.get_random_customs_items_maps(items_amount, allow_duplicate_items)
      map
    end

    sig { params(items_amount: Integer, allow_duplicate_items: T::Boolean).returns(T.nilable(EasyPost::CustomsInfo)) }
    public def get(items_amount, allow_duplicate_items)
      customs_info_map = get_map(items_amount, allow_duplicate_items)
      if customs_info_map.nil?
        raise "Could not load customs info map"
      end
      customs_info = EasyPost::CustomsInfo.create(**customs_info_map)
      customs_info
    end

  end

  class Events
    extend T::Sig
  end

  class Fees
    extend Mapper
    extend T::Sig

    sig { params(file_path: String).returns(T::Hash[String, T.untyped]) }
    private def get_map_from_json_file(file_path)
      Mapper.instance_method(:get_map_from_json_file).bind(self).call(file_path)
    end

    sig { params(file_path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    private def get_maps_from_json_file(file_path, amount, allow_duplicates)
      Mapper.instance_method(:get_maps_from_json_file).bind(self).call(file_path, amount, allow_duplicates)
    end

    sig { params(shipment_map: T.nilable(T::Hash[String, T.untyped]), shipment: T.nilable(EasyPost::Shipment)).returns(T.nilable(T::Array[T.untyped])) }
    public def get(shipment_map = nil, shipment = nil)
      begin
        if shipment.nil?
          if shipment_map.nil?
            shipment_map = EasyPostDevTools::Shipments.new.get_map(nil, nil)
          end
          shipment = EasyPost::Shipment.create(**shipment_map)
        end
        shipment.fees
      rescue
        nil
      end
    end
  end

  class Orders
    extend T::Sig
  end

  class Pickups
    extend Mapper
    extend T::Sig

    sig { params(file_path: String).returns(T::Hash[String, T.untyped]) }
    private def get_map_from_json_file(file_path)
      Mapper.instance_method(:get_map_from_json_file).bind(self).call(file_path)
    end

    sig { params(file_path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    private def get_maps_from_json_file(file_path, amount, allow_duplicates)
      Mapper.instance_method(:get_maps_from_json_file).bind(self).call(file_path, amount, allow_duplicates)
    end

    sig { returns(T.nilable(T::Hash[String, T.untyped])) }
    public def get_map
      map = get_map_from_json_file(Constants::PICKUPS_JSON)
      if map.nil?
        return nil
      end

      to_address_map = EasyPostDevTools::Addresses.new.get_map(nil, nil)
      from_address_map = EasyPostDevTools::Addresses.new.get_map(nil, nil)
      map['address'] = to_address_map

      parcel_map = EasyPostDevTools::Parcels.new.get_map

      shipment_map = EasyPostDevTools::Shipments.new.get_map(parcel_map, from_address_map, to_address_map)
      map['shipment'] = shipment_map
      dates = Dates.new.get_future_dates(2)
      map['min_datetime'] = dates[0]
      map['max_datetime'] = dates[1]
      map
    end
  end

  class Reports
    extend Mapper
    extend T::Sig

    sig { params(file_path: String).returns(T::Hash[String, T.untyped]) }
    private def get_map_from_json_file(file_path)
      Mapper.instance_method(:get_map_from_json_file).bind(self).call(file_path)
    end

    sig { params(file_path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    private def get_maps_from_json_file(file_path, amount, allow_duplicates)
      Mapper.instance_method(:get_maps_from_json_file).bind(self).call(file_path, amount, allow_duplicates)
    end

    sig { returns(T::Hash[String, T.untyped]) }
    public def get_map
      dates = Dates.new.get_past_dates(2)
      {
        'shipment' => {
          'start_date' => dates[1].to_s,
          'end_date' => dates[0].to_s
        }
      }
    end

    sig { returns(T.nilable(EasyPost::Report)) }
    public def get
      map = get_map
      EasyPost::Report.create(**map)
    end
  end

  class ScanForms
    extend T::Sig
  end

  class Webhooks
    extend Mapper
    extend T::Sig

    sig { params(file_path: String).returns(T::Hash[String, T.untyped]) }
    private def get_map_from_json_file(file_path)
      Mapper.instance_method(:get_map_from_json_file).bind(self).call(file_path)
    end

    sig { params(file_path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    private def get_maps_from_json_file(file_path, amount, allow_duplicates)
      Mapper.instance_method(:get_maps_from_json_file).bind(self).call(file_path, amount, allow_duplicates)
    end

    sig { returns(T::Hash[String, T.untyped]) }
    public def get_map
      {
        'url' => 'https://www.example.com/webhooks/test',
      }
    end

    sig { returns(T.nilable(EasyPost::Webhook)) }
    public def get
      map = get_map
      EasyPost::Webhook.create(**map)
    end
  end

  class Users
    extend T::Sig
  end

  class Carriers
    extend T::Sig

    sig { params(amount: Integer).returns(T::Array[String]) }
    public def get(amount = 1)
      JSONReader.new.get_random_items_from_json_file(Constants::CARRIERS_JSON, amount, false)
    end
  end

  class Labels
    extend Mapper
    extend T::Sig

    sig { params(file_path: String).returns(T::Hash[String, T.untyped]) }
    private def get_map_from_json_file(file_path)
      Mapper.instance_method(:get_map_from_json_file).bind(self).call(file_path)
    end

    sig { params(file_path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    private def get_maps_from_json_file(file_path, amount, allow_duplicates)
      Mapper.instance_method(:get_maps_from_json_file).bind(self).call(file_path, amount, allow_duplicates)
    end

    sig { returns(T.nilable(T::Hash[String, T.untyped])) }
    public def get_random_label_options
      get_map_from_json_file(Constants::LABEL_OPTIONS_JSON)
    end
  end

  class PostageLabels
    extend Mapper
    extend T::Sig

    sig { params(file_path: String).returns(T::Hash[String, T.untyped]) }
    private def get_map_from_json_file(file_path)
      Mapper.instance_method(:get_map_from_json_file).bind(self).call(file_path)
    end

    sig { params(file_path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
    private def get_maps_from_json_file(file_path, amount, allow_duplicates)
      Mapper.instance_method(:get_maps_from_json_file).bind(self).call(file_path, amount, allow_duplicates)
    end

    sig { params(shipment_map: T.nilable(T::Hash[String, T.untyped]), shipment: T.nilable(EasyPost::Shipment)).returns(T.nilable(EasyPost::PostageLabel)) }
    public def get(shipment_map = nil, shipment = nil)
      begin
        if shipment.nil?
          if shipment_map.nil?
            shipment_map = EasyPostDevTools::Shipments.new.get_map(nil, nil)
          end
          shipment = EasyPost::Shipment.create(**shipment_map)
        end
        shipment.postage_label
      rescue
        nil
      end
    end
  end

end
