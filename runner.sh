#!/bin/bash

OSDEBIAN='OpenStudio-2.2.2.ebdeaa44f8-Linux.deb'
EPLUSZIP='EnergyPlus-8.8.0-7c3bbe4830-Linux-x86_64.tar.gz'
UBUNTUFONTZIP='ubuntu-latex-fonts-master.zip'
INSTALLDIR='installers'

if [ $1 == "tests" ]; then
  bundle exec ruby tests/ts_all_tests.rb
  exit $?
elif [ $1 == "rubocop" ]; then
  bundle exec rubocop -D
  exit $?
elif [ $1 == "build" ]; then
  if [ ! -e "${INSTALLDIR}/${OSDEBIAN}" ]; then
    wget -O "${INSTALLDIR}/${OSDEBIAN}" "https://github.com/NREL/OpenStudio/releases/download/v2.2.2/${OSDEBIAN}"
  fi
  sudo gdebi -n "${INSTALLDIR}/${OSDEBIAN}"
  if [ ! -e "${INSTALLDIR}/${EPLUSZIP}" ]; then
    wget -O "${INSTALLDIR}/${EPLUSZIP}" "https://github.com/NREL/EnergyPlus/releases/download/v8.8.0/${EPLUSZIP}"
  fi
  tar -xf "${INSTALLDIR}/${EPLUSZIP}"
  if [ ! -e "${INSTALLDIR}/${UBUNTUFONTZIP}" ]; then
    wget -O "${INSTALLDIR}/${UBUNTUFONTZIP}" "https://github.com/tzwenn/ubuntu-latex-fonts/archive/master.zip"
  fi
  unzip "${INSTALLDIR}/${UBUNTUFONTZIP}"
  sudo make -C "ubuntu-latex-fonts-master" install
  bundle exec ruby lib/build_configurations.rb
  make -C report pdf
  exit $?
fi
