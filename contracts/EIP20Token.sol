// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract EIP20Token is ERC20 {
    constructor() ERC20("USDT", "USDT") {
        _mint(msg.sender, 1000000e6);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}
