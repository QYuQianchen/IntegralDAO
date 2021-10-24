import { BigInt, BigDecimal } from '@graphprotocol/graph-ts'
import { Transfer} from '../generated/HoprToken/HoprToken'
import { Account, Snapshot } from '../generated/schema'

/************************************
 ********** General Helpers *********
 ************************************/

export function exponentToBigDecimal(decimals: number): BigDecimal {
  let bd = BigDecimal.fromString('1')
  for (let i = 0; i < decimals; i++) {
    bd = bd.times(BigDecimal.fromString('10'))
  }
  return bd
}

export function bigDecimalExp18(): BigDecimal {
  return BigDecimal.fromString('1000000000000000000')
}


export function zeroBD(): BigDecimal {
  return BigDecimal.fromString('0')
}

export function zeroBigInt(): BigInt {
  return BigInt.fromI32(0)
}

export function oneBigInt(): BigInt {
  return BigInt.fromI32(1)
}

export function convertEthToDecimal(eth: BigInt): BigDecimal {
  return eth.toBigDecimal().div(exponentToBigDecimal(18))
}

/************************************
 ********* Specific Helpers *********
 ************************************/

export function getOrInitiateAccount(accountId: string): Account {
    let account = Account.load(accountId)

    if (account == null) {
        account = new Account(accountId)
        account.balance = zeroBD()
        account.integral = zeroBD()
        account.snapshotsCount = zeroBigInt()
        account.lastSnapshotAt = zeroBigInt()
    }

    return account as Account;
}

export function createFromSnapshot(event: Transfer, updatedBalance: BigDecimal, integralIncrement: BigDecimal): void {
    let fromSnapshotId = event.transaction.hash.toHex() + "-" + event.logIndex.toString() + "from"
    let fromSnapshot = new Snapshot(fromSnapshotId)
    fromSnapshot.account = event.params.from.toHex()
    fromSnapshot.updatedAtBlock = event.block.number
    fromSnapshot.updatedBalance = updatedBalance
    fromSnapshot.integralIncrement = integralIncrement
    fromSnapshot.save()
}

export function createToSnapshot(event: Transfer, updatedBalance: BigDecimal, integralIncrement: BigDecimal): void {
    let toSnapshotId = event.transaction.hash.toHex() + "-" + event.logIndex.toString() + "to"
    let toSnapshot = new Snapshot(toSnapshotId)
    toSnapshot.account = event.params.to.toHex()
    toSnapshot.updatedAtBlock = event.block.number
    toSnapshot.updatedBalance = updatedBalance
    toSnapshot.integralIncrement = integralIncrement
    toSnapshot.save()
}
