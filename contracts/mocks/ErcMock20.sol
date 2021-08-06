pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ErcMock20 is ERC20 {
  constructor (string memory name_, string memory symbol_)
    ERC20(name_, symbol_)
  { }

  function mint(uint amount) external {
    _mint(msg.sender, amount);
  }
}
