#!/bin/bash

if [ $1 == "tests" ]; then
  bundle exec ruby tests/ts_all_tests.rb && make -C report pdf
  exit $?
elif [ $1 == "rubocop" ]; then
  bundle exec rubocop -D
  exit $?
fi
