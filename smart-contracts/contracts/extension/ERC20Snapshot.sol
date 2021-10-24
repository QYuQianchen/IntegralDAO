// SPDX-License-Identifier: MIT

/**
 * @title Basic snapshot of an ERC-20 token
 * Simplified snapshot on the balance.
 */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../interface/IIntegral.sol";
import "../library/BalanceSnapshot.sol";

abstract contract ERC20Snapshot is IIntegral, BalanceSnapshot, ERC20 {
    /**
     * @dev Queries the balance of `account` at a specific `blockNumber`
     * @param account The address from which the balance will be retrieved
     * @param blockNumber The block number when the balance is queried
     * @return The balance at `blockNumber`
     */
    function balanceOfAt(address account, uint32 blockNumber) external view returns (uint224) {
        return _balanceAt(account, blockNumber);
    }

    /**
     * @dev Queries the weight of `account` at a specific `blockNumber`
     * @param account The address from which the balance will be retrieved
     * @param blockNumber The block number when the balance is queried
     * @return The weight at `blockNumber`
     */
    function weightOfAt(address account, uint32 blockNumber) external view returns (uint224) {
        return _weightAt(account, blockNumber);
    }

    /**
     * @dev Queries the increment in weight of `account` at a specific `blockNumber`
     * @param account The address from which the balance will be retrieved
     * @param blockNumber The block number when the balance is queried
     * @return The increment in weight at `blockNumber`
     */
    function weightChangeSince(address account, uint32 blockNumber) external view returns (uint224) {
        return _weightChangeSince(account, blockNumber);
    }

    /**
     * @dev hooks into OpenZeppelin's `ERC20._mint`, `ERC20._burn` and `ERC20._transfer` operations.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        
        if (from != to) {
            if (from != address(0)) {
                // update from
                _updateValueAtNow(from, _balanceAt(from, uint32(block.number)) - uint224(amount));
            }
            if (to != address(0)) {
                // update to
               _updateValueAtNow(to, _balanceAt(to, uint32(block.number)) + uint224(amount));
            }
        }
    }
}
