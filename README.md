# plant-pumping-overhaul

This is where I'll be storing scripts, files, and docs related to my plant pumping overhaul FY18 project.

## Setup

- Installing Ruby
  - This needs a 2.2.x version of Ruby for this to work with OpenStudio; I use 2.2.0
  - Install rbenv using the instructions [here](https://github.com/rbenv/rbenv#basic-github-checkout)
  - Install ruby-build **as an rbenv plugin** using the instructions [here](https://github.com/rbenv/ruby-build#installation)
  - Use rbenv to install Ruby 2.2.0 and set it as the local interpreter
- Install Gems
  - Install the bundler gem into Ruby 2.2.0
  - Get the gem dependencies, I prefer to put them in a local dir: `bundle install --path=vendor/bundle`
- Install Apt dependencies
  - Install LaTeX and Gnuplot with these apt packages: `gnuplot texlive-fonts-recommended texlive-latex-extra texlive-fonts-extra dvipng texlive-latex-recommended`
- Install E+ and OS
  - To install OpenStudio, download the Debian package from the release page (I used 2.2.2 - https://github.com/NREL/OpenStudio/releases/tag/v2.2.2) and install it
  - To install EnergyPlus, for this project, I am assuming it is available locally, so:
    - Download the binary zip package of 8.8.0 (https://github.com/NREL/EnergyPlus/releases/download/v8.8.0/EnergyPlus-8.8.0-7c3bbe4830-Linux-x86_64.tar.gz)
    - Extract it into the `plant-pumping-overhaul` directory so that the directory structure looks like: `/repos/plant-pumping-overhaul/EnergyPlus-8.8.0-7c3bbe4830-Linux-x86_64/EnergyPlus-8-8-0/...`

## Documentation [![Documentation Status](https://readthedocs.org/projects/plant-pumping-overhaul/badge/?version=latest)](http://plant-pumping-overhaul.readthedocs.io/en/latest/?badge=latest)

Documentation is hosted on [ReadTheDocs](http://plant-pumping-overhaul.readthedocs.io/en/latest/).  To build the documentation, enter the docs/ subdirectory and execute `make html`; then open `/docs/_build/html/index.html` to see the documentation.

## Testing [![Build Status](https://travis-ci.org/Myoldmopar/plant-pumping-overhaul.svg?branch=master)](https://travis-ci.org/Myoldmopar/plant-pumping-overhaul)

The source is tested using the Ruby test/unit framework.  To execute all the unit tests, just execute the main test suite file (which wraps all the other unit tests): `bundle exec ruby tests/ts_all_tests.rb`.  The tests are also executed by [Travis CI](https://travis-ci.org/Myoldmopar/plant-pumping-overhaul).
