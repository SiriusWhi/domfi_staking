// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.5;

import {Constants} from "./Constants.sol";
import {Errors} from "./Errors.sol";

/**
 * @title Collection of modifiers instead of using bloated utils
 */

abstract contract Modifiers is Constants,Errors {

    /**
     * @dev Simple Re-entrancy lock
     */
    uint256 private unlocked = 1;
    modifier nonReentrant() {
        require(unlocked == 1, REENTRANCY_LOCKED);
        unlocked = 0;
        _;
        unlocked = 1;
    }

    /**
     * @dev Only allow owner (i.e contract creator)
     */
    address internal owner;
    modifier onlyOwner() {
        require(msg.sender == owner, ONLY_OWNER);
        _;
    }

    /**
     * @dev Only allow after staking starts
     */
    bool internal stakingStarted;
    modifier afterStakingStarts() {
        require(stakingStarted, STAKING_NOT_STARTED);
        _;
    }

    function isContract(address _target) internal view returns (bool) {
        if (_target == address(0)) return false;

        uint256 size;

        assembly { size := extcodesize(_target) }
        return size > 0;
    }

}
