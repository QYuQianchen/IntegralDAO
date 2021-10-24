// SPDX-License-Identifier: MIT

/**
 * @title Basic snapshot of an ERC-155 token
 * Simplified snapshot on the balance.
 */

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../interface/IIntegral.sol";
import "../library/BalanceSnapshot.sol";

abstract contract ERC1155Snapshot is IIntegral, BalanceSnapshot, ERC1155 {
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
     * @dev hooks into OpenZeppelin's `ERC1155` operations.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint224 amount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            amount += uint224(amounts[i]);
        }

        if (from != to) {
            if (from != address(0)) {
                // update from
                _updateValueAtNow(from, _balanceAt(from, uint32(block.number)) - amount);
            }
            if (to != address(0)) {
                // update to
               _updateValueAtNow(to, _balanceAt(to, uint32(block.number)) + amount);
            }
        }
    }
}
