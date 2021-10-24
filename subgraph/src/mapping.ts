import { log } from '@graphprotocol/graph-ts'
import { Transfer} from '../generated/HoprToken/HoprToken'
import { getOrInitiateAccount, createFromSnapshot, createToSnapshot, oneBigInt } from './library';

export function handleTransfer(event: Transfer): void {
    log.info(`[ info ] Address of the account announcing itself: {}`, [event.params.from.toHex()]);
    let fromAccountId = event.params.from.toHex();
    let fromAccount = getOrInitiateAccount(fromAccountId)
    fromAccount.snapshotsCount = fromAccount.snapshotsCount.plus(oneBigInt())
    let newFromBalance = fromAccount.balance.minus(event.params.value.toBigDecimal())
    let fromIntegralIncrement = (event.block.number.minus(fromAccount.lastSnapshotAt)).toBigDecimal().times(fromAccount.balance)
    fromAccount.balance = newFromBalance
    fromAccount.integral = fromAccount.integral.plus(fromIntegralIncrement);
    fromAccount.save()
    createFromSnapshot(event, newFromBalance, fromIntegralIncrement)
    log.info(`[ info ] Address of the account announcing itself: {}`, [event.params.to.toHex()]);
    let toAccountId = event.params.to.toHex();
    let toAccount = getOrInitiateAccount(toAccountId)
    toAccount.snapshotsCount = toAccount.snapshotsCount.plus(oneBigInt())
    let newToBalance = toAccount.balance.plus(event.params.value.toBigDecimal())
    let toIntegralIncrement = (event.block.number.minus(fromAccount.lastSnapshotAt)).toBigDecimal().times(toAccount.balance)
    toAccount.balance = newToBalance
    toAccount.integral = toAccount.integral.plus(toIntegralIncrement);
    toAccount.save()
    createToSnapshot(event, newToBalance, toIntegralIncrement)
}