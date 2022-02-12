//
// Created by benny on 2022/2/2.
//

import Foundation

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

func sc_07_01() async {
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

class State {
    @MainActor var value: Int = 0

    @MainActor func update(value: Int) {
        log("update")
        self.value = value
    }
}

@MainActor
class UiState {
    var value: Int = 0

    func update(value: Int) {
        log("update")
        self.value = value
    }
}

func sc_07_02() async {
    let state = State()
    await state.update(value: 1)

    let uiState = await UiState()
    await uiState.update(value: 11)
}