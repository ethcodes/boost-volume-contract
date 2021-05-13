#!/usr/bin/env bash

if [ -d flats ]; then
  rm -rf flats
fi

mkdir -p flats

FLATTENER=./node_modules/.bin/truffle-flattener

echo "Flattening contracts"
${FLATTENER} contracts/BoostVolume.sol > flats/BoostVolume_Flat.sol
