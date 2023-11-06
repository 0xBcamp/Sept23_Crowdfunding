// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error AngelDollar_NotOwner();

contract AngelDollar is ERC20 {
    address private immutable i_owner;

    constructor(uint256 initialSupply) ERC20("Angel Dollar", "ADT") {
        i_owner = msg.sender;
        _mint(msg.sender, initialSupply * 10 ** 18);
    }

    modifier onlyOwner() {
        if (i_owner != msg.sender) revert AngelDollar_NotOwner();
        _;
    }

    function getOwnerAddress() public view returns (address) {
        return i_owner;
    }

    function mint(address account, uint256 amount) public onlyOwner {
        amount = amount * 10 ** 18;
        _mint(account, amount);
    }

    function burn(uint256 amount) public onlyOwner {
        amount = amount * 10 ** 18;
        _burn(msg.sender, amount);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account);
    }

    function totalSupply() public view override returns (uint256) {
        return super.totalSupply();
    }
}
