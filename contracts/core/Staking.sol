// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.5;

import {IERC900} from "../interfaces/IERC900.sol";
import {IERC20} from "../interfaces/IERC20.sol";

import {Modifiers} from "../utils/Modifiers.sol";

contract Staking is IERC900, Modifiers {

    /* Variables, Declarations and Constructor */

    // casting address to IERC20 interface
    IERC20 internal DOM;
    IERC20 internal LP;

    // total staked LP tokens
    uint256 private _totalStaked;

    // profile keeping track of stake and reward of user
    struct Account {
        uint256 staked;
        uint256 reward;
    }

    // mapping address to thier stake profile
    mapping(address => Account) private balances;

    constructor(address lpToken, address dom, uint256 totalDOM) {
        // set contract creator as owner
        owner = msg.sender;

        // check LP token address is actually contract
        require(isContract(lpToken), NOT_A_CONTRACT);
        LP_TOKEN = lpToken;
        LP = IERC20(LP_TOKEN);
        
        // check DOM token address is actually contract
        require(isContract(dom), NOT_A_CONTRACT);
        DOM_TOKEN = dom;
        DOM = IERC20(DOM_TOKEN);

        // total DOM distributed for rewards should not be zero
        require(totalDOM != 0, ZERO_AMOUNT);
        TOTAL_DOM = totalDOM;
    }

    /* State changing functions */

    // to initialize the staking start time after depositing DOM
    function initialize() external onlyOwner {
        // this contract must have enough DOM to allow to start staking
        require(DOM.balanceOf(address(this)) >= TOTAL_DOM, NOT_ENOUGH_DOM);
        // allow to call initialize() only once by checking if it was initialized before
        require(STAKING_START_TIMESTAMP == 0, STAKING_ENDED_OR_NOT_STARTED);
    
        // change staking allowed from false(default) to true
        stakingAllowed = true;
        // mark timestamp of when staking was initialized
        STAKING_START_TIMESTAMP = block.timestamp;
    }

    function stake(uint256 _amount) external override duringStaking checkPeriod nonReentrant {
        _stakeFor(msg.sender, msg.sender, _amount);
    }

    function stakeFor(address _user, uint256 _amount) external override duringStaking checkPeriod nonReentrant {
        _stakeFor(msg.sender, _user, _amount);
    }

    function unstake(uint256 _amount) external override nonReentrant {
        _unstake(msg.sender, _amount);
    }

    /* View functions */

    function stakingToken() external view override returns (address) {
        return LP_TOKEN;
    }

    function rewardToken() external view override returns (address) {
        return DOM_TOKEN;
    }

    function totalStaked() external view override returns (uint256) {
        return _totalStaked;
    }

    function remainingDOM() external view returns (uint256) {
        return DOM.balanceOf(address(this));
    }
    
    function totalStakedFor(address _addr) external view override returns (uint256)  {
        return balances[_addr].staked;
    }

    function totalRewardsFor(address _addr) external view returns (uint256)  {
        return balances[_addr].reward;
    }

    function supportsHistory() external pure override returns (bool) {
        return false;
    }

    /* Internal functions */

    function _stakeFor(address _from, address _user, uint256 _amount) internal {
        // do not allow to stake zero amount
        require(_amount > 0, ZERO_AMOUNT);

        // rebalance rewards and penalty according to current ongoing phase
        _rebalance(_user);

        // check this contract has been given enough allowance on behalf of who is transferring
        // so this contract can transfer LP tokens into itself to lock
        require(LP.allowance(_from, address(this)) >= _amount, NOT_ENOUGH_ALLOWANCE );

        // transfer LP tokens to itself for locking
        LP.transferFrom(_from, address(this), _amount);

        // increase user balance and total balance
        balances[_user].staked += _amount;
        _totalStaked += _amount;

        // rebalance rewards and penalty according to current ongoing phase
        _rebalance(_user);
    }

    function _unstake(address _from, uint256 _amount) internal {
        // do not allow to unstake zero amount
        require(_amount > 0, ZERO_AMOUNT);

        // rebalance rewards and penalty according to current ongoing phase
        _rebalance(_from);

        // subtract LP tokens from user's staked LP tokens and total staked LP tokens
        balances[_from].staked -= _amount;
        _totalStaked -= _amount;

        // transfer back substracted LP tokens
        LP.transfer(_from, _amount);

        // transfer back stake earning of DOM if total DOM earned is > 0
        if(balances[_from].reward > 0) DOM.transfer(_from, balances[_from].reward);

        // rebalance rewards and penalty according to current ongoing phase
        _rebalance(_from);
    }

    function _rebalance(address _user) internal {
        // share of user out of total staked
        uint256 s = balances[_user].staked / _totalStaked;

        // to keep track of rewards and penalty
        (uint256 reward, uint256 penalty) = _getRewardsAndPenalties();

        // update dom rewards for the user
        balances[_user].reward = DOM.balanceOf(address(this)) * s * reward * (1 - penalty);
    }

    function _getRewardsAndPenalties() internal view returns (uint256 _reward, uint256 _penalty) {
        // days since staking started
        uint256 x = (block.timestamp - STAKING_START_TIMESTAMP) / 86400;

        if(x < 7)
        { // first 7 days, stake deposit period
            _reward  = 0  ;
            _penalty = 1  ;
        }
        else if(x >= 7 && x < REWARD_PERIOD)
        { // after first 7 days until active period (120 days)
            _reward  = ( (x-7)**2 )  /  ( (LSP_PERIOD-7)**2 ) ;
            _penalty = 1 - (  (x-7) / (REWARD_PERIOD-7)  )    ;
        }
        else if(x >= REWARD_PERIOD && x < LSP_PERIOD)
        { // between active period and LSP expiry period
            _reward  = ( (x-7)**2 )  /  ( (LSP_PERIOD-7)**2 ) ;
            _penalty = 0                                      ;
        }
        else
        { // after LSP expiry period
            _reward  = 1  ;
            _penalty = 0  ;
        }
    }

}
