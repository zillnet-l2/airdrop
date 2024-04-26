#/bin/bash
set -e

cd `dirname $0`
source .env

function create_l1_token(){
    forge create src/Token.sol:Token --constructor-args $1 $2 $3 $4 --private-key $PRIVATE_KEY --rpc-url $L1_RPC --json
}

function create_l2_token(){
    cast send 0x4200000000000000000000000000000000000012 "createOptimismMintableERC20WithDecimals(address,string,string,uint8)" $1 $2 $3 $4 --private-key $PRIVATE_KEY --rpc-url $L2_RPC --json
}

l1_usdt=`create_l1_token USDT USDT 100000000000000 6 | jq -r '.deployedTo'`
l1_usdc=`create_l1_token USDC USDC 100000000000000 6 | jq -r '.deployedTo'`
l1_wbtc=`create_l1_token WBTC WBTC 10000000000000000 8 | jq -r '.deployedTo'`
l1_dai=`create_l1_token DAI DAI 100000000000000000000000000 18 | jq -r '.deployedTo'`

l2_usdt=`create_l2_token $l1_usdt USDT USDT 6 | jq -r '.logs[0].topics[2]' | cast parse-bytes32-address`
l2_usdc=`create_l2_token $l1_usdc USDC USDC 6 | jq -r '.logs[0].topics[2]' | cast parse-bytes32-address`
l2_wbtc=`create_l2_token $l1_wbtc WBTC WBTC 8 | jq -r '.logs[0].topics[2]' | cast parse-bytes32-address`
l2_dai=`create_l2_token $l1_dai DAI DAI 18  | jq -r '.logs[0].topics[2]' | cast parse-bytes32-address`

echo "$l1_usdt $l2_usdt USDT"
echo "$l1_usdc $l2_usdc USDC"
echo "$l1_wbtc $l2_wbtc WBTC"
echo "$l1_dai $l2_dai DAI"
