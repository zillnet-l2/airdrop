// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

error AlreadyClaimed(); //646cf558
error InvalidProof(); //09bde339
error StartInPast(); //635fce19
error NotStarted(); //6f312cbd

contract Refund is Ownable {
    bytes32 public root; // merkle root
    uint256 public start;
    uint256 public distributed;
    mapping(address => uint256) public history;
    uint256 public count; // addresses count
    mapping(uint256 => uint256) private claimed; // A packed array of booleans

    event Claimed(uint256 index, address account, uint256 amount);

    constructor(address _owner) Ownable(_owner) {}

    function update(bytes32 _root, uint256 _start) public payable onlyOwner {
        if (_start <= block.timestamp) revert StartInPast();
        root = _root;
        start = _start;
    }

    function isClaimed(uint256 index) public view returns (bool) {
        uint256 rowIndex = index / 256;
        uint256 colIndex = index % 256;
        uint256 row = claimed[rowIndex];
        uint256 mask = (1 << colIndex);
        return row & mask == mask;
    }

    function _setClaimed(uint256 index) private {
        uint256 rowIndex = index / 256;
        uint256 colIndex = index % 256;
        claimed[rowIndex] = claimed[rowIndex] | (1 << colIndex);
    }

    function claim(
        uint256 index,
        uint256 amount,
        bytes32[] calldata proofs
    ) public {
        if (isClaimed(index)) revert AlreadyClaimed();
        if (start == 0 || block.timestamp < start) revert NotStarted();

        // Verify the merkle proof.
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(index, msg.sender, amount)))
        );
        if (!MerkleProof.verify(proofs, root, leaf)) revert InvalidProof();

        // Mark it claimed and send the fund.
        _setClaimed(index);
        payable(msg.sender).transfer(amount);

        if (history[msg.sender] == 0) {
            count++;
        }
        history[msg.sender] += amount;
        distributed += amount;
        emit Claimed(index, msg.sender, amount);
    }
}
