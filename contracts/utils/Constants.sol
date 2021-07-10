// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.5;

abstract contract Constants {

    address internal LP_TOKEN;
    address internal DOM_TOKEN;

    uint256 internal constant STAKING_PERIOD = 7 days;
    uint256 internal constant PENALTY_PERIOD = 7 days;
    uint256 internal constant EARNING_PERIOD = 120 days;

    uint256 internal TOTAL_DOM;

}
