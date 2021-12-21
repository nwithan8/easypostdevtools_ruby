# typed: true

require 'json'
require 'easypostdevtools/random'

class JSONReader
  extend T::Sig

  sig { params(path: String).returns(T::Array[T.untyped]) }
  private def read_json_file_json(path)
    json_file = File.read(path)
    JSON.parse(json_file)
  end

  sig { params(path: String).returns(T::Array[T.untyped]) }
  private def read_json_file_array(path)
    json_file = File.read(path)
    JSON.parse(json_file)
  end

  sig { params(path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T::Hash[String, T.untyped]]) }
  public def get_random_maps_from_json_file(path, amount, allow_duplicates = false)
    data = read_json_file_json(path)
    Random.new.get_random_items_from_list(data, amount, allow_duplicates)
  end

  sig { params(path: String, amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T.untyped]) }
  public def get_random_items_from_json_file(path, amount, allow_duplicates = false)
    data = read_json_file_array(path)
    Random.new.get_random_items_from_list(data, amount, allow_duplicates)
  end
end
