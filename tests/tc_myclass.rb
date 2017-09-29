require_relative '../lib/myclass'
require 'test/unit'
require 'gnuplot'

# This unit tests does simple testing
class TestMyClass < Test::Unit::TestCase
  def test_simple
    m = MyClass.new
    assert_equal(4, m.add_two(2))
    assert_equal(5, m.add_two(3))
  end
  def test_again
    Gnuplot.open do |gp|
      Gnuplot::Plot.new( gp ) do |plot|
        plot.terminal "png"
        plot.output File.expand_path('/tmp/test.png', __FILE__)
        plot.xrange "[-10:10]"
        plot.title  "Sin Wave Example"
        plot.ylabel "x"
        plot.xlabel "sin(x)"

        x = (0..50).collect { |v| v.to_f }
        y = x.collect { |v| v ** 2 }

        plot.data = [
          Gnuplot::DataSet.new( "sin(x)" ) { |ds|
            ds.with = "lines"
            ds.title = "String function"
            ds.linewidth = 4
          },

          Gnuplot::DataSet.new( [x, y] ) { |ds|
            ds.with = "linespoints"
            ds.title = "Array data"
          }
        ]
      end
    end
  end
end
