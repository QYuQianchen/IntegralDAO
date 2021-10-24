// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

/**
 * @title Basic snapshot on token balance
 ^ @notice It essentially treats all tokens as ERC20.
 */

contract BalanceSnapshot {
    /// @notice To make the most use out of ERC20Vote, type of balance is set to uint224
    struct Snapshot {
        uint32 fromBlock;
        // number of owned NFTs
        uint224 balance;
        // weight of balance over time
        uint224 weight;
    }

    mapping (address => BalanceSnapshot.Snapshot[]) internal _snapshots;

    /**
     * @dev Retrieves the number of tokens at a given block number
     * @param account The address from which the balance will be retrieved
     * @param blockNumber The block number when the balance is queried
     * @return The number of tokens being queried
     */
    function _balanceAt(
        address account,
        uint32 blockNumber
    ) view internal returns (uint224) {
        Snapshot[] memory snapshots = _snapshots[account];
        uint256 lenSnapshots = snapshots.length;
        if (lenSnapshots == 0) return 0;

        // Shortcut for the actual value
        if (blockNumber >= snapshots[lenSnapshots - 1].fromBlock) {
            return snapshots[lenSnapshots - 1].balance;
        }
        if (blockNumber < snapshots[0].fromBlock) {
            return 0;
        }

        // Binary search of the value in the array
        uint256 min = 0;
        uint256 max = lenSnapshots - 1;
        while (max > min) {
            uint256 mid = (max + min + 1) / 2;

            uint256 midSnapshotFrom = snapshots[mid].fromBlock;
            if (midSnapshotFrom == blockNumber) {
                return snapshots[mid].balance;
            } else if (midSnapshotFrom < blockNumber) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }

        return snapshots[min].balance;
    }

    /**
     * @dev Retrieves the weight of tokens at a given block number
     * @param account The address from which the balance will be retrieved
     * @param blockNumber The block number when the balance is queried
     * @return The weight of tokens being queried
     */
    function _weightAt(
        address account,
        uint32 blockNumber
    ) view internal returns (uint224) {
        Snapshot[] memory snapshots = _snapshots[account];
        uint256 lenSnapshots = snapshots.length;
        if (lenSnapshots == 0) return 0;

        // Shortcut for the actual value
        if (blockNumber >= snapshots[lenSnapshots - 1].fromBlock) {
            return snapshots[lenSnapshots - 1].weight + (blockNumber - snapshots[lenSnapshots - 1].fromBlock) * (snapshots[lenSnapshots - 1].balance);
        }
        if (blockNumber < snapshots[0].fromBlock) {
            return 0;
        }

        // Binary search of the value in the array
        uint256 min = 0;
        uint256 max = lenSnapshots - 1;
        while (max > min) {
            uint256 mid = (max + min + 1) / 2;

            uint256 midSnapshotFrom = snapshots[mid].fromBlock;
            if (midSnapshotFrom == blockNumber) {
                return snapshots[mid].balance;
            } else if (midSnapshotFrom < blockNumber) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }

        return snapshots[min].weight + (blockNumber - snapshots[min].fromBlock) * snapshots[min].balance;
    }

    /**
     * @dev Retrieves the weight increase of tokens at a given block number
     * @param account The address from which the balance will be retrieved
     * @param blockNumber The block number since when the weight is queried
     * @return The weight increase of tokens being queried
     */
    function _weightChangeSince(
        address account,
        uint32 blockNumber
    ) view internal returns (uint224) {
        Snapshot[] memory snapshots = _snapshots[account];
        uint256 lenSnapshots = snapshots.length;
        if (lenSnapshots == 0) return 0;

        // Shortcut for the actual value
        if (blockNumber >= snapshots[lenSnapshots - 1].fromBlock) {
            return (uint32(block.number) - blockNumber) * (snapshots[lenSnapshots - 1].balance);
        }
        if (blockNumber < snapshots[0].fromBlock) {
            return snapshots[lenSnapshots - 1].weight + (uint32(block.number) - snapshots[lenSnapshots - 1].fromBlock) * (snapshots[lenSnapshots - 1].balance);
        }

        // Binary search to get index from the array
        uint256 min = 0;
        uint256 max = lenSnapshots - 1;
        while (max > min) {
            uint256 mid = (max + min + 1) / 2;

            uint256 midSnapshotFrom = snapshots[mid].fromBlock;
            if (midSnapshotFrom == blockNumber) {
                return snapshots[mid].balance;
            } else if (midSnapshotFrom < blockNumber) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        uint256 index = min + 1;
        // weight of current interval
        uint224 weight = (snapshots[index].fromBlock - blockNumber) * snapshots[index].weight / (snapshots[index].fromBlock - snapshots[min].fromBlock);

        while (index < lenSnapshots - 1) {
            index ++;
            weight += snapshots[index].weight;
        }
        uint32 duration = (uint32(block.number) - snapshots[lenSnapshots - 1].fromBlock);
        weight += snapshots[lenSnapshots - 1].balance * duration;
        return weight;
    }

     /**
     * @dev update snapshots for current block
     * @param account The address from which the balance will be retrieved
     * @param balance The new number of tokens
     */
    function _updateValueAtNow(address account, uint224 balance) internal {
        Snapshot[] memory snapshots = _snapshots[account];
        uint256 lenSnapshots = snapshots.length;

        if (lenSnapshots == 0) {
            // include a new snapshot
            _snapshots[account].push(
                Snapshot(
                    uint32(block.number),
                    balance,
                    uint224(0)
                )
            );
        } else if (snapshots[lenSnapshots - 1].fromBlock < uint32(block.number)) {
            // update calculation on the weight
            Snapshot memory lastSnapshot = snapshots[lenSnapshots - 1];
            uint224 weight = lastSnapshot.weight + lastSnapshot.balance * (uint32(block.number) - lastSnapshot.fromBlock);
            // include a new snapshot
            _snapshots[account].push(
                Snapshot(
                    uint32(block.number),
                    balance,
                    weight
                )
            );
        } else {
            snapshots[lenSnapshots - 1].balance = balance;
        }
    }
}