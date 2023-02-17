// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Pausable} from "../lib/openzeppelin-contracts/contracts/security/Pausable.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

abstract contract PausableWithOwner is Ownable, Pausable {
    function pause() public virtual onlyOwner whenNotPaused {
        _pause();
        emit Paused(msg.sender);
    }

    function unpause() public virtual onlyOwner whenPaused {
        _unpause();
        emit Unpaused(msg.sender);
    }
}
