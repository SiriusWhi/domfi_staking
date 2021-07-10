// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.5;


/**
 * @title Collection of modifiers instead of using bloated utils
 */

abstract contract Modifiers {

    uint private unlocked = 1;

    /**
     * @dev Simple Re-entrancy lock
     */
    modifier nonReentrant() {
        require(unlocked == 1, 'REENTRANCY_LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

}
