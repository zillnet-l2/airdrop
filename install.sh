#!/bin/env bash
set -e

cd `dirname $0`

forge install --no-git forge-std=foundry-rs/forge-std@v1.8.1
forge install --no-git openzeppelin-contracts=OpenZeppelin/openzeppelin-contracts@v5.0.2

