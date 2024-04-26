// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Token is ERC20, ERC165, ERC20Permit {

    uint8 private immutable DECIMALS;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _supply,
        uint8 _decimals
    ) ERC20(_name, _symbol) ERC20Permit(_name) {
        DECIMALS=_decimals;
        _mint(msg.sender, _supply);
    }

    function decimals() public view virtual override returns (uint8) {
        return DECIMALS;
    }
}