require_relative '../lib/myclass'
require 'test/unit'

# This unit test does simple testing
class TestMyClass < Test::Unit::TestCase
  def test_simple
    m = MyClass.new
    assert_equal(4, m.add_two(2))
    assert_equal(5, m.add_two(3))
  end
end
