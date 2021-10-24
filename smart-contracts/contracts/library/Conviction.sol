// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

/**
 * @dev Library for calculating conviction of a project with elapsed time of
 * hodling project's asset.
 * 
 * Conviction is calculated according to https://hackmd.io/[at]dapplion/rJMvfgOv4
 * At an obvservation block (t blocks further since the last balance change),
 * conviction (y_t) has the following formula
 *
 *   y_t = (a ** t) * y_0 + x * (1 - a ** t) / (1 - a)
 *
 * where:
 * - y_t is the conviction at the obervation block
 * - y_0 is the conviction at last block where the token balance gets changed
 * - x is the token balance since the last change
 * - a is the decay factor
 *
 * Solidity implementation: 
 *   D = 2 ** 8
 *   a = aD / D. E.g. when a is 0.9, aD should be 230
 *   Dt = D ** t
 *   aDt = aD ** t;
 *   y = (aDt * y0 + (x * D * (Dt - aDt)) / (D-aD)) / Dt;
 * Note that the maxinum value of balance / conviction is at 2 ** 224
 */
library Conviction {
    /**
     * This storage is not the most efficient. However to take the most out of
     * ERC20Vote, type of conviction and balance is aligned to uint224
     */
    struct ConvictionCheckpoint {
        uint224 lastConviction;
        uint224 lastBalance;
    }

    /**
     * @dev Calculate the conviction value at the observation block, which is  
     * {elapsedBlock} since the last change in balance
     *
     * Returns the conviction value at observation
     */
    function _valueAt(ConvictionCheckpoint memory lastCheckpoint, uint224 delayNumerator, uint32 elapsedBlock) private pure returns (uint224) {
        uint224 delayDemoninator = 2<<7;
        uint224 dt = delayDemoninator ** elapsedBlock;
        uint224 adt = delayNumerator ** elapsedBlock;
        return (adt * lastCheckpoint.lastConviction + (lastCheckpoint.lastBalance * delayDemoninator * (dt - adt)) / ((delayDemoninator - uint224(delayNumerator)))) / dt;
    }

    /**
     * @dev Create a check point with an increse in balance since last check
     * @param lastCheckpoint The last checkpoint based on which changes get calculated.
     * @param delayNumerator Numerator of the delay factor. Denominator is 2 ** 8
     * @param elapsedBlock The number of blocks passed by since the last change
     * @param difference Increment of difference. 
     */
    function _addBalance(ConvictionCheckpoint memory lastCheckpoint, uint224 delayNumerator, uint32 elapsedBlock, uint224 difference) private returns (ConvictionCheckpoint memory) {
        uint224 lastConviction = _valueAt(lastCheckpoint, delayNumerator, elapsedBlock);
        return ConvictionCheckpoint(lastConviction, lastCheckpoint.lastBalance + difference);
    }

    /**
     * @dev Create a check point with a decrease in balance since last check
     * @param lastCheckpoint The last checkpoint based on which changes get calculated.
     * @param delayNumerator Numerator of the delay factor. Denominator is 2 ** 8
     * @param elapsedBlock The number of blocks passed by since the last change
     * @param difference Decrease of difference.
     */
    function _reduceBalance(ConvictionCheckpoint memory lastCheckpoint, uint224 delayNumerator, uint32 elapsedBlock, uint224 difference) private returns (ConvictionCheckpoint memory) {
        // No need to compare the difference with the current balance, because underflow
        // will be catched by the 
        uint224 lastConviction = _valueAt(lastCheckpoint, delayNumerator, elapsedBlock);
        return ConvictionCheckpoint(lastConviction, lastCheckpoint.lastBalance - difference);
    }
}