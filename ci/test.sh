#!/bin/bash

set -e -x

pushd lita-alertlogic
  bundle install
  bundle exec rspec
popd
