# typed: ignore
# frozen_string_literal: true

require "test_helper"

class EasyPostDevToolsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::EasyPostDevTools::VERSION
  end

  def test_it_does_something_useful
    assert false
  end

  def main
    num = EasyPostDevTools::Constants::Addresses::Country::COUNTRY::UNITED_STATES.address_file
  end
end
