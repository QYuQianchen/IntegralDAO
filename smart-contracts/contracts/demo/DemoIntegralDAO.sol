// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.6;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../IntegralDelegatable.sol";

/**
 * Create a demo integral DAO token for a integral DAO protocol compatible token.
 */
contract DemoIntegralDAO is Ownable, ERC20, IntegralDelegatable {
    /**
     * @param token Address of the underlying tracked token
     */
    constructor(
        address token
    ) IntegralDelegatable(token) 
      ERC20("Integral Checkpointable", "iCheckpointable") 
      ERC20Permit("iCheckpointable") {}

    /**
     * @dev Get the address `account` is currently delegating to.
     */
    function delegates(address account) public view override(IntegralDelegatable) returns (address) {
        return super.delegates(account) == address(0) ? account : super.delegates(account);
    }

    /**
     * @dev Snapshots the totalSupply after it has been increased.
     */
    function _mint(address account, uint256 amount) internal virtual override (ERC20, IntegralDelegatable) {
        super._mint(account, amount);
    }

    /**
     * @dev Snapshots the totalSupply after it has been decreased.
     */
    function _burn(address account, uint256 amount) internal virtual override (ERC20, IntegralDelegatable) {
        super._burn(account, amount);
    }

    /**
     * @dev Move voting power when tokens are transferred.
     *
     * Emits a {DelegateVotesChanged} event.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override (ERC20, IntegralDelegatable) {
        super._afterTokenTransfer(delegates(from), delegates(to), amount);
    }

    /**
     * @dev Change delegation for `delegator` to `delegatee`.
     *
     * Emits events {DelegateChanged} and {DelegateVotesChanged}.
     */
    function _delegate(address delegator, address delegatee) internal override (IntegralDelegatable) {
        super._delegate(delegator, delegatee);
    }
}