// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract DominationToken is ERC20Burnable {
    string internal _name = "Domination Finance Token";
    string internal _symbol = "DOM";
    uint internal INITIAL_SUPPLY = 331718750 * 10**18;

    constructor() ERC20(
        _name,
        _symbol
    ) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
