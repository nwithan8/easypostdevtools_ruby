# typed: true

require 'kernel'

class Random
  extend T::Sig
  sig { returns(T::Boolean) }
  public def get_random_boolean
    rand(0..1) == 0
  end

  sig { params(min: Integer, max: Integer).returns(Integer) }
  public def get_random_int_in_range(min, max)
    rand(min..max)
  end

  sig { returns(Integer) }
  public def get_random_int
    get_random_int_in_range(0, 100)
  end

  sig { params(min: Float, max: Float).returns(Float) }
  public def get_random_double_in_range(min, max)
    rand(min..max)
  end

  sig { returns(Float) }
  public def get_random_double
    get_random_double_in_range(0.0, 100.0)
  end

  sig { params(min: Float, max: Float).returns(Float) }
  public def get_random_float_in_range(min, max)
    rand(min..max)
  end

  sig { returns(Float) }
  public def get_random_float
    get_random_float_in_range(0.0, 100.0)
  end

  sig { returns(String) }
  public def get_random_char
    ('a'..'z').to_a[0]
  end

  sig { params(length: Integer).returns(String) }
  public def get_random_string(length)
    if length.nil?
      length = get_random_int_in_range(1, 10)
    end
    (0...length).map { ('a'..'z').to_a[rand(26)] }.join
  end

  sig { params(list: T::Array[T.untyped], amount: Integer, allow_duplicates: T::Boolean).returns(T::Array[T.untyped]) }
  public def get_random_items_from_list(list, amount, allow_duplicates = false)
    if allow_duplicates && amount > list.length
      Kernel::raise "Amount must be less than or equal to list size when unique is true"
    end
    items = []
    (0..amount - 1).each { |i|
      item = list[get_random_int_in_range(0, list.length - 1)]
      items.push(item)
      unless allow_duplicates
        list.delete(item)
      end
    }
    items
  end

  sig { params(list: T::Array[T.untyped]).returns(T.nilable(T.untyped)) }
  public def get_random_item_from_list(list)
    items = get_random_items_from_list(list, 1, false)
    items[0]
  end
end
