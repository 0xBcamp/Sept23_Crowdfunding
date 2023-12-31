// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error NotOwner();

contract AngelGovernanceToken is ERC20 {
    address private immutable i_owner;
    address private lockTokensContract;

    constructor() ERC20("Angel Governance Token", "AGT") {
        i_owner = msg.sender;
        // _mint(msg.sender, 1000 * 10 ** decimals());
    }

    modifier onlyOwner() {
        if (i_owner != msg.sender) revert NotOwner();
        _;
    }

    function getOwnerAddress() public view returns (address) {
        return i_owner;
    }

    function setLockTokensContract(address _lockTokensContract) public onlyOwner {
        require(_lockTokensContract != address(0), "Address cannot be zero");
        lockTokensContract = _lockTokensContract;
    }

    function mint(address account, uint256 amount) public {
        require( /*transferEnabled || */
            msg.sender == i_owner || msg.sender == lockTokensContract, "Transfers are not enabled."
        );
        _mint(account, amount);
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account);
    }

    function totalSupply() public view override returns (uint256) {
        return super.totalSupply();
    }

    function viewLockTokensContractAddress() public view returns (address) {
        return lockTokensContract;
    }
}
