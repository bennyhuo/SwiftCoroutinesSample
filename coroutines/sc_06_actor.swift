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

        nonisolated

    func hash(into hasher: inout Hasher) {
        hasher.combine(accountNumber)
    }

        nonisolated
    var hashValue: Int {
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

func runOnMain(block: @MainActor @escaping () -> Void) async {
    log("runOnMain before")
    await block()
    log("runOnMain after")
}

@globalActor actor MyActor: GlobalActor {
    public typealias ActorType = MyActor

    static let shared: MyActor = MyActor()

    private static let _sharedExecutor = MyExecutor()

    static let sharedUnownedExecutor: UnownedSerialExecutor = _sharedExecutor.asUnownedSerialExecutor()

    let unownedExecutor: UnownedSerialExecutor = sharedUnownedExecutor
}

final class MyExecutor : SerialExecutor {

    private static let dispatcher: DispatchQueue = DispatchQueue(label: "MyActor")

    func enqueue(_ job: UnownedJob) {
        log("enqueue")
        MyExecutor.dispatcher.async {
            job._runSynchronously(on: self.asUnownedSerialExecutor())
        }
    }

    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

func runOnMyExecutor(block: @MyActor @escaping () async -> Void) async {
    log("runOnMyExecutor start")
    await block()
    log("runOnMyExecutor end")
}

func runOnMain(block: @MainActor @escaping () async -> Void) async {
    log("runOnMyExecutor start")
    await block()
    log("runOnMyExecutor end")
}

@MyActor func calledOnMyExecutor() {
    log("onMyExecutor")
}

@MainActor func calledOnMain() {
    log("onMain")
}

func sc_06_02() async {
    await Task { () -> Int in
        log("task start")
//        await calledOnMain()
        await runOnMain {
            await Task {
                log("task in runOnMain")
            }.value

            await Task.detached {
                log("detached task in runOnMain")
            }.value
        }

//        await calledOnMyExecutor()
//        await runOnMyExecutor {
//            log("on MyExecutor before sleep")
//            await Task.sleep(1000_000_000)
//            log("on MyExecutor after sleep")
//        }


        log("task end")
        return 1
    }.value
}
