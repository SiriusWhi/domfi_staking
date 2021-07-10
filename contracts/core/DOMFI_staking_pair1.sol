// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.5;

import {IERC900} from "../interfaces/IERC900.sol";
import {IERC20} from "../interfaces/IERC20.sol";

import {Modifiers} from "../utils/Modifiers.sol";
import {Constants} from "./Constants.sol";
import {Errors} from "./Errors.sol";

contract Pair1 is IERC900, Modifiers {
    function stake(uint256 _amount, bytes calldata _data) external override {}
    function stakeFor(address _user, uint256 _amount, bytes calldata _data) external override {}
    function unstake(uint256 _amount, bytes calldata _data) external override {}
    function totalStakedFor(address _addr) external view override returns (uint256)  {}
    function totalStaked() external view override returns (uint256) {}
    function token() external view override returns (address) {}
    function supportsHistory() external pure override returns (bool) {}
}
