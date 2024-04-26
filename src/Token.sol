// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Token is ERC20, ERC165, ERC20Permit {

    uint8 private _decimals;

    constructor(
        string memory name,
        string memory symbol,
        uint256 supply,
        uint8 dec
    ) ERC20(name, symbol) ERC20Permit(name) {
        _decimals=dec;
        _mint(msg.sender, supply);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}