// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.5;

import {IERC900} from "../interfaces/IERC900.sol";
import {IERC20} from "../interfaces/IERC20.sol";

import {Modifiers} from "../utils/Modifiers.sol";

contract Staking is IERC900, Modifiers {

    IERC20 internal DOM;
    IERC20 internal LP;

    constructor(address lpToken, address dom, uint256 totalDOM) {
        owner = msg.sender;

        require(isContract(lpToken), NOT_A_CONTRACT);
        LP_TOKEN = lpToken;
        LP = IERC20(LP_TOKEN);
        
        require(isContract(lpToken), NOT_A_CONTRACT);
        DOM_TOKEN = dom;
        DOM = IERC20(DOM_TOKEN);

        require(totalDOM != 0, ZERO_AMOUNT);
        TOTAL_DOM = totalDOM;
    }

    function initialize() external onlyOwner {
        require(DOM.balanceOf(address(this)) >= TOTAL_DOM, NOT_ENOUGH_DOM);
        stakingStarted = true;
    }

    function stake(uint256 _amount, bytes calldata _data) external override afterStakingStarts {}

    function stakeFor(address _user, uint256 _amount, bytes calldata _data) external override afterStakingStarts {}

    function unstake(uint256 _amount, bytes calldata _data) external override afterStakingStarts {}
    
    function totalStakedFor(address _addr) external view override returns (uint256)  {}

    function totalStaked() external view override returns (uint256) {}

    function token() external view override returns (address) {}

    function supportsHistory() external pure override returns (bool) {}
}
