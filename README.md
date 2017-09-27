# plant-pumping-overhaul

This is where I'll be storing scripts, files, and docs related to my plant pumping overhaul FY18 project.

## Documentation [![Documentation Status](https://readthedocs.org/projects/plant-pumping-overhaul/badge/?version=latest)](http://plant-pumping-overhaul.readthedocs.io/en/latest/?badge=latest)

Documentation is hosted on [ReadTheDocs](http://plant-pumping-overhaul.readthedocs.io/en/latest/).  To build the documentation, enter the docs/ subdirectory and execute `make html`; then open `/docs/_build/html/index.html` to see the documentation.

## Testing [![Build Status](https://travis-ci.org/Myoldmopar/plant-pumping-overhaul.svg?branch=master)](https://travis-ci.org/Myoldmopar/plant-pumping-overhaul)

The source is tested using the Ruby test/unit framework.  To execute all the unit tests, just execute the main test suite file (which wraps all the other unit tests): `bundle exec ruby tests/ts_all_tests.rb`.  The tests are also executed by [Travis CI](https://travis-ci.org/Myoldmopar/plant-pumping-overhaul).
