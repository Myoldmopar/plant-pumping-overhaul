#!/bin/bash

if [ $1 == "tests" ]; then
  bundle exec ruby tests/ts_all_tests.rb && make -C report pdf
  exit $?
elif [ $1 == "rubocop" ]; then
  bundle exec rubocop -D
  exit $?
elif [ $1 == "build" ]; then
  wget https://github.com/NREL/OpenStudio/releases/download/v2.2.2/OpenStudio-2.2.2.ebdeaa44f8-Linux.deb
  sudo gdebi -n OpenStudio-2.2.2.ebdeaa44f8-Linux.deb
  wget https://github.com/NREL/EnergyPlus/releases/download/v8.8.0/EnergyPlus-8.8.0-7c3bbe4830-Linux-x86_64.tar.gz
  tar -xvf EnergyPlus-8.8.0-7c3bbe4830-Linux-x86_64.tar.gz
  bundle exec ruby lib/build_configurations.rb
  exit $?
fi
