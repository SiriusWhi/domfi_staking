# Smart Contract Challenge

The following challenge is designed to asses your ability of understanding of solidity, and smart contracts in the Ethereum ecosystem. Please follow the instructions carefully.

Contract code: 
[https://github.com/ferrosync/domfi-staking/blob/master/contracts/Destaking.sol](https://github.com/ferrosync/domfi-staking/blob/master/contracts/Destaking.sol)

## 1. Read the contract above, and answer the following questions:

- **Q** What constructor parameters should I use to simulate a bond with 2% annual yield. Assuming the maximum staking cap is *1,000,000 DOM*
- **Q** Given a staking contract with the following parameters, find the actual amounts each user gets at withdraw:
```
- Staking ends:   1 oct 2019
- Maturity:       1 oct 2020
- Staking cap:    1,000,000 DOM
- Reward:         200,000 DOM
- Early withdrawable rewards: 50,000 DOM


Alice has staked 250,000 DOM.
Bob has staked 500,000 DOM.

Alice withdraws 200,000 on 1 may 2020, how much does she get including rewards (X)
Bob withdraws 500,000 DOM on 1 nov 2020, how much does he get including rewards (Y) 
Alice withdraws 50,000 on 1 may 2020, how much does she get including rewards (Z)
```

## 2. Critical analysis

Write which parts of the code you can improve. Write a short and to the point critical report, as you are code reviewing.

## 3. Find the bug

Look at the code very carefully, you can install it on a test environment (or testnet) and run it. See if you can spot bugs leading to potential missuse of the funds or people losing money. Review solidity security best practices to find potential candidates.

## 4. Add feature

Add compounded interest to withdraw rewards.

