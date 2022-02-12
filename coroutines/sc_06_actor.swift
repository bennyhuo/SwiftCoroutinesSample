//
// Created by benny on 2022/2/2.
//

import Foundation

actor BankAccount {
    let accountNumber: Int
    var balance: Double

    init(accountNumber: Int, initialDeposit: Double) {
        self.accountNumber = accountNumber
        self.balance = initialDeposit
    }
}

extension BankAccount {
    func deposit(amount: Double) async {
        assert(amount >= 0)
        balance = balance + amount
    }
}

extension BankAccount: CustomStringConvertible {
    nonisolated
    var description: String {
        "Bank account #\(accountNumber)"
    }
}

extension BankAccount: Hashable {
    static func ==(lhs: BankAccount, rhs: BankAccount) -> Bool {
        lhs.accountNumber == rhs.accountNumber
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(accountNumber)
    }

    nonisolated var hashValue: Int {
        get {
            accountNumber.hashValue
        }
    }
}

func deposit(amount: Double, to account: isolated BankAccount) {
    assert(amount >= 0)
    account.balance = account.balance + amount
}

func sc_06_01() async throws {
    let account = BankAccount(accountNumber: 1234, initialDeposit: 1000)
    print(account.accountNumber)
    print(await account.balance)

    let account2 = account
    await account2.deposit(amount: 90)
    await deposit(amount: 1000, to: account)
    print(await account.balance)

    print(account === account2)
    print(account)

}