# This defines a simple class
class MyClass
  def add_two(x)
    fail unless x.is_a?(Numeric)
    x + 2
  end
end
