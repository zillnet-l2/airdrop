#/bin/bash
set -e

cd `dirname $0`
source .env

forge create src/Token.sol:Token --constructor-args USDT USDT 100000000000000 6 --private-key $PRIVATE_KEY
forge create src/Token.sol:Token --constructor-args USDC USDC 100000000000000 6 --private-key $PRIVATE_KEY
forge create src/Token.sol:Token --constructor-args WBTC WBTC 10000000000000000 8 --private-key $PRIVATE_KEY
forge create src/Token.sol:Token --constructor-args DAI DAI 100000000000000000000000000 18 --private-key $PRIVATE_KEY
