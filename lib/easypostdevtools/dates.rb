# typed: true

require 'kernel'

class Dates
  extend T::Sig

  sig { params(date: DateTime).returns(T::Boolean) }
  private def is_leap_year(date)
    year = date.year
    year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
  end

  sig { params(month: Integer, year: Integer).returns(Integer) }
  private def get_last_day_of_month(month, year)
    date = Date.new(year, month, 1).to_datetime
    if [1, 3, 5, 7, 8, 10, 12].include?(date.month)
      31
    elsif [4, 6, 9, 11].include?(date.month)
      30
    elsif date.month == 2
      is_leap_year(date) ? 29 : 28
    else
      raise "Invalid month: #{date.month}"
    end
  end

  sig { params(date: DateTime).returns(T::Boolean) }
  private def is_last_day_of_month(date)
    date.day == get_last_day_of_month(date.month, date.year)
  end

  sig { params(date: DateTime).returns(T::Boolean) }
  private def is_last_month_of_year(date)
    date.month == 12
  end

  sig { params(date: DateTime).returns(T::Boolean) }
  private def is_last_day_of_year(date)
    date.month == 12 && date.day == 31
  end

  sig { returns(DateTime) }
  public def get_future_date_this_year
    if is_last_day_of_year(DateTime.now)
      raise "This year is over."
    end

    if is_last_day_of_month(DateTime.now)
      # pull from next month on
      month = Random.new.get_random_int_in_range(DateTime.now.month + 1, 12)
    else
      # pull from next day on
      month = Random.new.get_random_int_in_range(DateTime.now.month, 12)
    end

    max_days = get_last_day_of_month(month, DateTime.now.year)
    if month == DateTime.now.month
      # pull from tomorrow on
      day = Random.new.get_random_int_in_range(DateTime.now.day, max_days)
    else
      # pull from first day of month
      day = Random.new.get_random_int_in_range(1, max_days)
    end
    Date.new(DateTime.now.year, month, day).to_datetime
  end

  sig { returns(DateTime) }
  public def get_future_date_this_month
    if is_last_day_of_month(DateTime.now)
      raise "This month is over."
    end
    max_days = get_last_day_of_month(DateTime.now.month, DateTime.now.year)
    day = Random.new.get_random_int_in_range(DateTime.now.day + 1, max_days)

    Date.new(DateTime.now.year, DateTime.now.month, day).to_datetime
  end

  sig { params(date: DateTime).returns(DateTime) }
  public def get_date_after(date)
    if date.month == 12
      # if it's December, set up the next date to be in January
      date = Date.new(date.year + 1, 1, 1).to_datetime
    end
    (date + Random.new.get_random_int_in_range(1, 30)).to_datetime
  end

  sig { params(date: DateTime).returns(DateTime) }
  public def get_date_before(date)
    if date.month == 1
      # if it's January, set up the next date to be in December
      date = Date.new(date.year - 1, 12, 31).to_datetime
    end
    (date - Random.new.get_random_int_in_range(1, 30)).to_datetime
  end

  sig { params(number_of_dates: Integer).returns(T::Array[DateTime]) }
  public def get_future_dates(number_of_dates)
    dates = []
    current_date = DateTime.now
    (1..number_of_dates).each { |i|
      current_date = get_date_after(current_date)
      dates << current_date
    }
    dates
  end

  sig { params(number_of_dates: Integer).returns(T::Array[DateTime]) }
  public def get_past_dates(number_of_dates)
    dates = []
    current_date = DateTime.now
    (1..number_of_dates).each { |i|
      current_date = get_date_before(current_date)
      dates << current_date
    }
    dates
  end

end
