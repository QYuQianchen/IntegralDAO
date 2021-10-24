// SPDX-License-Identifier: MIT

/**
 * @title Basic snapshot of an ERC-777 token
 * Simplified snapshot on the balance, which essentially treat it as ERC20.
 */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "../interface/IIntegral.sol";
import "../library/BalanceSnapshot.sol";

abstract contract ERC777Snapshot is IIntegral, BalanceSnapshot, ERC777 {
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
     * @dev hooks into OpenZeppelin's `ERC777._mint`, `ERC777._burn` and `ERC777._transfer` operations.
     */
    function _beforeTokenTransfer(address operator, address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, amount);
        
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
