#!/bin/bash

if [ $1 == "tests" ]; then
  bundle exec ruby tests/ts_all_tests.rb && make -C report pdf
  exit $?
elif [ $1 == "rubocop" ]; then
  bundle exec rubocop -D
  exit $?
elif [ $1 == "build" ]; then
  wget https://github.com/NREL/OpenStudio/releases/download/v2.2.2/OpenStudio-2.2.2.ebdeaa44f8-Linux.deb
  sudo gdebi OpenStudio-2.2.2.ebdeaa44f8-Linux.deb
  bundle exec lib/build_configurations.rb
  exit $?
fi
